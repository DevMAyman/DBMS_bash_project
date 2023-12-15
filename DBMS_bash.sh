#! /bin/bash
# welcome to my user and mention his/her user name
#--------------------------------------------------------------------------------------------------------------------You must enter number only---------------------------------------------------------------------
function ValidateNumirecInput (){
if [[ $1 = +([0-9]) ]];then
return 0
else
echo "Please Enter numbers only"
return 1
fi
}
function ValidateDTNumirecInput (){
if [[ $1 = *([0-9]) || $1 == "null"  ]]
then
echo "Data type validate successfully"
return 0
else
echo "Please Enter numbers only"
return 1
fi
}
orderRowsByPK (){
PK_fields=0
PK_fields=$(awk  -F ':' '{ for (i = 1; i <= NF; i++) {if( $i == "PK" ){ print NR; exit;}}}' ./"$1"/."$2.metadata") 
PK_type=$(awk  -F ':' '{ for (i = 1; i <= NF; i++) {if( $i == "PK" ){ print $2; exit;}}}' ./"$1"/."$2.metadata") 
all_rows=$(wc -l < ./"$1"/"$2")
if [[ $PK_fields != "" ]]; then
((all_rows=${all_rows}-1))
head -1 ./"$1"/"$2" >> ./temp
if [[ $PK_type == "int" ]]; then
tail -"$all_rows" ./"$1"/"$2" | sort -t':' -k"$PK_fields","$PK_fields"n  >> ./temp
else
tail -"$all_rows" ./"$1"/"$2" | sort -t':' -k"$PK_fields","$PK_fields"  >> ./temp
fi
mv ./temp ./"$1"/"$tbname"
fi

}
#-------------------------------------------------------------------------------------------------------check uniqness(insert)---------------------------------------------------------------------------------
##check_uniqueness $1 $tab_name $col_value $var $4
function check_uniqueness (){
PK_fields=$(awk  -F ':' -v col_num=$4 -v col_val=$3 '{if (col_val == $col_num) {print 1;exit;}}' ./"$1"/"$2") 
return $PK_fields
}
##check_uniqueness $1 $tab_name $col_value $var $4 $NR
## اذا كان هناك تعديل ابديت لقيمة ال pk هناك ثلاث احتمالات ... لو انا باثر فى اكثر من سطر اكيد مسنفعش و لوانا باثر فى سطر واحد لازم تروح تتاكد من عدم وجود قيمة التغيير فى اي صف ما عدا الصف اللى يحصل عليه تعديل
function check_uniquenessForUpdate (){
PK_fields=$(awk  -F ':' -v col_num=$4 -v col_val=$3 -v row_num=$5 '{if (col_val == $col_num && NR != row_num) {print 1;exit;}}' ./"$1"/"$2") 
return $PK_fields
}
#-------------------------------------------------------------------------------------------------------NULL or Not NULL-----------------------------------------------------------------------------------------
# parameters : $1 $tab_name $c $col_value
function chechNull (){
((line_number_in_metadatafile=$3+1))
is_null=$(head -$line_number_in_metadatafile ./"$1"/."$2.metadata" | tail -1 | awk -F ':' '{print $3}') #$3 is the third field (null,not_null)
if [[ $is_null = not_null && ( -z "$4" || "$4" = null )   ]]; then
echo "Not ok, your column is not_null and you insert no thing"
return 1
elif [[ $is_null = null && -z "$4"  ]]; then
echo "ok, your column is null and you insert no thing"
return 2
else
echo "okay about null check"
return 0
fi
}
#--------------------------------------------------------------------------------------------------Int or String--------------------------------------------------------------
# parameters : $1 $tab_name $c $col_value
function VlidateDatatype (){

((line_num=$3+1))
dataType=$(head -$line_num ./"$1"/".$2.metadata" | tail -1 | awk -F ':' '{print $2}') #$2 is the second field (int,string)
 
if [[ $dataType = int   ]]; then 
ValidateDTNumirecInput $4  #Must be modified ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
var=$?
return $var
else
echo "Data type checked successfully"
fi
}
#------------------------------------------------------------------------------------------------------Validate first char in name-----------------------------------------------------------------------------------------
function validateDBobjectName (){
if [[ $1 =~ ^[A-Za-z]+ ]]; then
return 0
else
echo not valid name, do not start with number or special charachter.
return 1 
fi
}
#-------------------------------------------------------------------------------------------------List table function-------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------List table function-------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------List table function-------------------------------------------------------------------------------------------------
function list_table(){
#-p  add / to directory , -E for extended regix
ls -p ./"$1" | grep -vE '.metadata$|/' 
}
#-------------------------------------------------------------------------------------------------Drop table function-------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------Drop table function-------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------Drop table function-------------------------------------------------------------------------------------------------
function drop_table (){
cd ./$1
read -p "Enter the table name to delete : " tbname
if [[ -f "$tbname" ]]; then
rm "$tbname" ".$tbname.metadata"
echo "Table deleted successfully"
cd ../
else
echo "There is no table with this name"
echo "Your tables at ${1} databse are :" 
ls -p  | grep -vE '.metadata$|/' 
cd ../
fi
}
#---------------------------------------------------------------------------------------------------Delete table function--------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------Delete table function--------------------------------------------------------------------------------------------------------------
deleteFromTable (){
#----------------------------------------------------------------------------------------------------check table exist------------------------------------------------------------------------------------------------------------------
var=1
while [[ $var = 1 ]]
do
read -p "Enter table name to select : " tbname
if [[ -f "./"$1"/"$tbname"" ]]; then
var=0
else
echo "This name does not exist"
continue
fi
done
#-------------------------------------------------------------------------------------------------where condition will start-------------------------------------------------------------------------------------------
var=1
while [[ $var = 1 ]]
do
echo "Do you want where condition?"
echo "1) Yes" 
echo "2) No"
#echo "enter 1 or 2"
read is_condition
if [[ $is_condition == 1 ]]; then
var=where_applied
elif [[ $is_condition == 2 ]]; then
var=no_where_applied
else
var=1
continue
fi
done

#----------------------------------------------------------------------------------------------------------if there is where condition----------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------take column and value condition--------------------------------------------------------------------------------------------------
while [[ $var = where_applied ]]
do
read -p "Enter column that holds your condtion : " col_condtion
where_col_exist=$(head -1 ./"$1"/"$tbname" | awk -F ':' -v name=$col_condtion '{ for (i = 1; i <= NF; i++) { if ($i==name) { print i;exit; } } }') # the awk check in the first line in table data and return 0 if column found
if [[ $where_col_exist == "" ]]; then
echo "Col does not exist!" 
var=where_applied
continue
else
echo "Col exists!"
read -p "Enter your value" value
break
fi
done
#------------------------------------------------------------------------------------------------------------------if where applied select will start------------------------------------------------------------------------------
no_row=0
all_rows=$(wc -l < ./"$1"/"$tbname")
if [[ $var = where_applied ]]; then
awk -F ':' -v aw_where_col_num="$where_col_exist" -v val="$value"  '{if ($aw_where_col_num != val || NR==1) {print $0;}}' ./"$1"/"$tbname" >> ./temp
no_row=$(awk -F ':' -v aw_where_col_num="$where_col_exist" -v val="$value" 'BEGIN { aw_no_row=0 } {if ($aw_where_col_num != val || NR == 1) { aw_no_row++ } } END { print aw_no_row }' ./"$1"/"$tbname")
#------------------------------------------------------------------------------------------------------------------if no where applied select will start------------------------------------------------------------------------------
elif [[ $var = no_where_applied ]]; then
awk -v no_row=$no_row '{if(NR == 1){print $0;}' ./"$1"/"$tbname" >> ./temp
no_row=$(awk  'BEGIN{no_row=0}{if(NR == 1) {no_row++} END {print no_row}' ./"$1"/"$tbname")
fi
mv ./temp ./"$1"/"$tbname"
affected_rows=$((${all_rows} - ${no_row}))
echo s"$affected_rows row(s) affected"
}




#---------------------------------------------------------------------------------------------------Select table function--------------------------------------------------------------------------------------------------------------
function selectFromTable(){
#----------------------------------------------------------------------------------------------------check table exist------------------------------------------------------------------------------------------------------------------
var=1
while [[ $var = 1 ]]
do
read -p "Enter table name to select : " tbname
if [[ -f "./"$1"/"$tbname"" ]]; then
var=0
else
echo "This name does not exist"
continue
fi
done
#----------------------------------------------------------------------------------------Enter columns want be select------------------------------------------------------------------------------------------------------------------
select_var=1
while [[ $select_var = 1 ]]
do
echo "Do you want to select all (*) or specific columns ?"
echo "1) select all (*)"
echo "2) specific columns"
read select_state
if [[ $select_state != 1 && $select_state != 2 ]]; then
echo "Please Enter 1 or 2"
continue
else
select_var=0
fi
done
#---------------------------------------------------------------------------------select * all ----------------------------------------------------------------------------------------------------------------------
col_my_array=()
if [[ $select_state == 1 ]]; then
#awk '{print $0}' ./"$1"/"$tbname"
output_awk=$(head -1 ./"$1"/"$tbname" | awk -F ':' -v name=$col_name '{ for (i = 1; i <= NF; i++) { print i;  } }')
mapfile -t col_my_array <<< "$output_awk"
#echo "${col_my_array[1]}"
fi

#---------------------------------------------------------------------------------select specific cols ----------------------------------------------------------------------------------------------------------------------
if [[ $select_state == 2 ]]; then
my_array=()
col_my_array=()
i_want_continue=yes
while [[ $i_want_continue = yes ]]
do 
read -p "Enter column you want to select from : " col_name
length=${#my_array[@]}
col_exist_before=0
for ((i=0; i<length; i++)); do
    if [[ ${my_array[i]} == $col_name ]]; then
        col_exist_before=1
    break
    fi
done
if [[ $col_exist_before == 1 ]]; then
echo "You enter this before"
continue
fi
col_exist=$(head -1 ./"$1"/"$tbname" | awk -F ':' -v name=$col_name '{ for (i = 1; i <= NF; i++) { if ($i==name) { print i;exit; } } }') # the awk check in the first line in table data and return 0 if column found
if [[ $col_exist == "" ]]; then 
echo "Column name dosen't exist"
continue
fi
my_array+=("$col_name")
col_my_array+=("$col_exist")  # number of columns 
#-------------------------------------------------------------------------------------want add another column-------------------------------------------------------------------------------------------
var_invalid=no
((my_length=$length+1))
no_col=$(head -1 ./"$1"/"$tbname" | awk -F ':' '{print NF}')
if [[ $my_length == $no_col ]]; then #### اخرج لو اليوزر دخل الحد الاقصي من ال ؤخمعةىس
i_want_continue=No
break
fi
while [[ $var_invalid = no ]]
do
echo "Do you want select from another column?"
echo "1) Yes"
echo "2)No"
read  var
if [[ $velar = Yes || (($var = 1)) ]]; then
i_want_continue=yes
var_invalid=yes
elif [[ $var = No || (($var = 2)) ]]; then
i_want_continue=No
var_invalid=yes
else
echo "Enter valid input"
var_invalid=no
fi
done
done

#echo "${col_my_array[1]}"
fi
#-------------------------------------------------------------------------------------------------where condition will start-------------------------------------------------------------------------------------------
var=1
while [[ $var = 1 ]]
do
echo "Do you want where condition?"
echo "1) Yes" 
echo "2) No"
#echo "enter 1 or 2"
read is_condition
if [[ $is_condition == 1 ]]; then
var=where_applied
elif [[ $is_condition == 2 ]]; then
var=no_where_applied
else
var=1
continue
fi
done

#----------------------------------------------------------------------------------------------------------if there is where condition----------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------take column and value condition--------------------------------------------------------------------------------------------------
while [[ $var = where_applied ]]
do
read -p "Enter column that holds your condtion : " col_condtion
where_col_exist=$(head -1 ./"$1"/"$tbname" | awk -F ':' -v name=$col_condtion '{ for (i = 1; i <= NF; i++) { if ($i==name) { print i;exit; } } }') # the awk check in the first line in table data and return 0 if column found
if [[ $where_col_exist == "" ]]; then
echo "Col does not exist!" 
var=where_applied
continue
else
echo "Col exists!"
read -p "Enter your value" value
break
fi
done
#------------------------------------------------------------------------------------------------------------------if where applied select will start------------------------------------------------------------------------------
no_row_affect=0
array_string=$(IFS=,; echo "${col_my_array[*]}")
if [[ $var = where_applied ]]; then
awk -F ':' -v aw_where_col_num="$where_col_exist" -v val="$value" '{if ($aw_where_col_num == val || NR==1) {print $0}}' ./"$1"/"$tbname" | cut -d':' -f "$array_string" | column -t -s ":"
#------------------------------------------------------------------------------------------------------------------if no where applied select will start------------------------------------------------------------------------------
elif [[ $var = no_where_applied ]]; then
awk '{print $0}' ./"$1"/"$tbname" | cut -d':' -f "$array_string" | column -t -s ":"
fi
}
#--------------------------------------------------------------------------------------------------Update table function-----------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------Update table function-----------------------------------------------------------------------------------------------
function updateTable () {
#------------------check table exist-------------
var=1
while [[ $var = 1 ]]
do
read -p "Enter table name to updtae : " tbname
if [[ -f "./"$1"/"$tbname"" ]]; then
var=0
else
echo "This name does not exist"
continue
fi
done
#-----------------check column exist--------------
var=1
while [[ $var = 1 ]]
do 
read -p "Enter column you want to update in : " col_name
col_exist=$(head -1 ./"$1"/"$tbname" | awk -F ':' -v name=$col_name '{ for (i = 1; i <= NF; i++) { if ($i==name) { print i;exit; } } }') # the awk check in the first line in table data and return 0 if column found
if [[ $col_exist == "" ]]; then 
echo "Column name dosen't exist"
continue
else
var=0
fi
done
#----------------call Validate data type function-----------------------------------------------------------------------------------------------------------
var1=1
while [[ $var1 = 1 ]]
do
((col_num=$col_exist-1))
read -p "Enter your new value : " new_value  
VlidateDatatype $1 $tbname $col_num $new_value
var1=$?
if [[ $var1 = 1 ]]; then
continue
else
var1=0
fi
#--------------call null check function--------------------
chechNull $1 $tbname $col_num $new_value
var1=$?
if [[ $var1 = 1 ]]; then
continue

fi
if [[ $var1 = 2 ]]; then   #add null if user enter nothing and your column allow null
new_value=null
fi
done
#
#------------------------------------------------------------------------------------------Where Condtion------------------------------
pk_exist=$(head -$col_exist ./"$1"/".${tbname}.metadata" | tail -1 | awk -F ':' '{print $4}') #number of column
#echo $4
if [[ $pk_exist = PK ]]; then
var=where_applied
else
var=1
while [[ $var = 1 ]]
do
echo "Do you want where condition?"
echo "1) Yes" "2) No"
#echo "enter 1 or 2"
read is_condition
if [[ $is_condition == 1 ]]; then
var=where_applied
elif [[ $is_condition == 2 ]]; then
var=no_where_applied
else
var=1
continue
fi
done
fi
#################################################Where#########################################

while [[ $var = where_applied ]]
do
read -p "Enter column that holds your condtion : " col_condtion
where_col_exist=$(head -1 ./"$1"/"$tbname" | awk -F ':' -v name=$col_condtion '{ for (i = 1; i <= NF; i++) { if ($i==name) { print i;exit; } } }') # the awk check in the first line in table data and return 0 if column found
if [[ $where_col_exist == "" ]]; then
echo "Col does not exist!" 
var=where_applied
continue
else
echo "Col exists!"
break
fi
done

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
var1=1
while [[ $var = where_applied && $var1 = 1 ]]
do
read -p "Enter your value" value
if [[ $value = "" ]]; then   #add null if user enter nothing and your column allow null
value=null
fi
no_row_affect=0
no_row_affect=$(awk -F  ':' -v aw_where_col_num="$where_col_exist" -v val="$value" -v aw_new_value="$new_value" -v aw_col_exist="$col_exist" -v aw_no_row_affect=$no_row_affect '{ if ($aw_where_col_num == val && NR != 1) {aw_no_row_affect++; }} END {print aw_no_row_affect;} ' ./"$1"/"$tbname")

#-----------------check column condtion exist--------------------------------------------------
pk_exist=$(head -$col_exist ./"$1"/".${tbname}.metadata" | tail -1 | awk -F ':' '{print $4}') #number of column
#echo $4
if [[ $pk_exist = PK ]]; then
row_number=$(awk -F  ':' -v aw_where_col_num="$where_col_exist" -v val="$value" -v aw_new_value="$new_value" -v aw_col_exist="$col_exist" -v aw_no_row_affect=$no_row_affect '{ if ($aw_where_col_num == val && NR != 1) {print NR}} ' ./"$1"/"$tbname")
unique_val=0
check_uniquenessForUpdate $1 $tbname $new_value $col_exist $row_number
unique_val=$?
if [[ $no_row_affect > 1 ]]; then
echo "Your condition affect more than one row and you upadte pk so update must be unique"
var1=1
continue
elif [[ $unique_val = 1 && $no_row_affect == 1 ]]; then
echo "You must enter unique value"
var1=1
continue
else
var1=0ss
echo "Okay about unique"
fi
else
var1=0
fi
done
#-------------------------------------------------------------substitute-----------------------------------------------------------------------------------------------------
if [[ $var = where_applied ]]; then
awk -F  ':' -v aw_where_col_num="$where_col_exist" -v val="$value" -v aw_new_value="$new_value" -v aw_col_exist="$col_exist" -v aw_no_row_affect=$no_row_affect '{ if ($aw_where_col_num == val && NR != 1) {OFS = FS; $aw_col_exist = aw_new_value;}} 1' ./"$1"/"$tbname" > ./"$1"/temp
mv ./"$1"/temp ./"$1"/"$tbname"
echo "$no_row_affect row(s) affected"
elif [[ $var = no_where_applied ]]; then
awk -F  ':' -v aw_where_col_num="$where_col_exist" -v aw_new_value="$new_value" -v aw_col_exist="$col_exist" -v aw_no_row_affect=$no_row_affect '{  if (NR != 1){ OFS = FS; $aw_col_exist = aw_new_value;}} 1' ./"$1"/"$tbname" > ./"$1"/temp
mv ./"$1"/temp ./"$1"/"$tbname"
#no_row_affect=$(awk '{ END {print NR} } ' ./"$1"/"$tbname")
no_row_affect=$(wc -l < ./"$1"/"$tbname")
((no_row_affect=$no_row_affect-1))
echo "$no_row_affect row(s) affected"
fi
orderRowsByPK "$1" "$tbname"  
}




#-------------------------------------------------------------------------------------------------Create table function-------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------Create table function-------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------Create table function-------------------------------------------------------------------------------------------------
function createTable (){
tablecreated=false
# will create table here 
var=1
while [[ $var = 1 ]]
do
read -p "Enter table name :" tbname
validateDBobjectName $tbname
var=$?
if [[ $var = 1 ]]; then
continue
fi 
########
if [[ -f "./"$1"/"$tbname"" ]]
then
echo "Table already exist"
var=1
continue	
else
#######
touch ./"$1"/"$tbname"
touch ./"$1"/."$tbname.metadata"	
echo "Table created successfully"
tablecreated=true
var=0

fi
done
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if [[ $tablecreated = true ]]; then
var=1
while [[ $var = 1 ]]
do 
read -p "Enter number of columns :" col_num
ValidateNumirecInput $col_num
var=$?
if [[ $col_num == 0 && $var == 0 ]]; then
var=1
echo "Number of columns can't be 0"
continue
fi
if [[ $var = 1 ]]; then
continue
fi
done
#------------------------------------------------if number of columns =1 do not ask him about number of pk column number and set it to 1 -----------------------------------------------------------------------------
if [[ $col_num = 1 ]]; then
echo $col_num
PK_col_num=1
fi
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
var=1
while (( $var == 1 && $col_num != 1 ))
do
read -p "Enter number of PK col :" PK_col_num
ValidateNumirecInput $PK_col_num
var=$?
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if [[ $PK_col_num > $col_num ]]; then
var=1
echo "Please Enter number between or equal to 1 and ${col_num}"
continue
fi
if [[ $var = 1 ]]; then
continue
fi
done
 #--------------------------------------take data from user will start know-----------------------------------------------------------------------------------------------------------------------------------------------
for (( i=0; i< $col_num ; i++ ))
do
  #--------------------------------------------------column name-----------------------------------------------------------------------------------------------------------------------------------------------------------
  read -p "Enter the name of column $(($i+1)) :" col_name
  validateDBobjectName "$col_name"
  var=$?
  if [[ $var = 1 ]]; then
  ((i--))
  continue
  fi
  #--------------------------------------------------DataType--------------------------------------------------------------------------------------------------------------------------------------------------------------
  echo "what is your data type"
  select choice in "string" "int" 
  do
  case $REPLY in
  1) 
  col_type=string
  break
  ;;
  2)
  col_type=int
  break
  ;;
  *)
  echo "Enter valid choice 1 or 2"
  ;;
  esac
  done
#-----------------------------------------------------------------------------------------------------------------null or not null-------------------------------------------------------------------------------------------------
    is_primary_key=no
  if (( (($i+1)) != $PK_col_num )); then
  echo "Do your column allow null"
  select choice in "null" "not null"
  do
  case $REPLY in
  1) 
  col_null=null
  break
  ;;
  2)
  col_null=not_null
  break
  ;;
  *)
  echo "Enter valid choice 1 or 2"
  ;;
  esac
  done
  elif (( (($i+1)) == $PK_col_num )); then
  echo "This is a primary key column so it will be not null by default"
  col_null=not_null
  is_primary_key=yes
  fi
#---------------------------------------------------push my variable into table and metadata-------------------------------------------------
    #echo $PWD
    if [[ $is_primary_key = no ]]; then
    echo "${col_name}:${col_type}:${col_null}" >> ../database/"$1"/".${tbname}.metadata"
    elif [[ $is_primary_key = yes ]]; then
    echo "${col_name}:${col_type}:${col_null}:"PK"" >> ../database/"$1"/".${tbname}.metadata"
    fi
    if (( $i == (($col_num-1)) )); then
    echo  "${col_name}" >> ../database/"$1"/"$tbname"
    else
    echo -n "${col_name}:" >> ../database/"$1"/"$tbname"
    fi
done
fi
}
#-------------------------------------------------------------------------------------------------Insert in table function-------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------Insert in table function-------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------Insert in table function-------------------------------------------------------------------------------------------------
insertInTable (){
in_var=1
while [[ $in_var = 1 ]]
do
read -p "enter table name : " tab_name
if [[ -f "./"$1"/"$tab_name"" ]]; then
in_var=0
else
echo "This name does not exist"
continue
fi
done
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
let num_col=$(awk -F ':' '{print NF}' ./"$1"/"$tab_name") #number of column
#echo $num_col
i_want_continue=yes
while [[ $i_want_continue = yes ]]
do
for (( c=0; c<$num_col; c++ ))
do
in_col_name=$(head -1  ./"$1"/"$tab_name" | awk -v var=$(($c+1)) -F ':' '{print $var}')
read -p "Enter the value for column ${in_col_name} : " col_value
#-------------------------------------------------------------------------------------------call validate datatype function---------------------------------------------------------------------------------------
# $1 is the dbname,$c is the field number for tabledata and line number for metadata,
VlidateDatatype $1 $tab_name $c $col_value
dataType=$?
if [[ $dataType = 1 ]]; then
((c=$c-1))
continue
fi
#------------------------------------------------------------------------------------------- call check null function----------------------------------------------------------------------------------------------
# $1 is the dbname,$c is the field number for tabledata and line number for metadata,
chechNull $1 $tab_name $c $col_value
is_null=$?
if [[ $is_null = 1 ]]; then
((c=$c-1))
continue
fi
#----------------------------------------------------------------------------------------------check uniquenes ---------------------------------------------------------------------------------------------------
let var=$c+1
pk_exist=$(head -$var ./"$1"/".${tab_name}.metadata" | tail -1 | awk -F ':' '{print $4}') #number of column
#echo $4
if [[ $pk_exist = PK ]]; then
check_uniqueness $1 $tab_name $col_value $var
unique_val=$?
if [[ $unique_val = 1 ]]; then
echo "You must enter unique value"
((c=$c-1))
continue
fi
fi

#--------------------------------------------------------------------------------------------Append in table after 3 validation-----------------------------------------------------------------------------------
if [[ $is_null = 2 ]]; then   #add null if user enter nothing and your column allow null
col_value=null
fi
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if (( $c == 0 )); then
echo -n "${col_value}:" >> ./"$1"/"$tab_name"
elif (( $c == (($num_col-1)) )); then
echo  "${col_value}" >> ./"$1"/"$tab_name"
else
echo -n "${col_value}:" >> ./"$1"/"$tab_name"
fi
#--------------------------------------------------------------------------------------------insert another row or exit-----------------------------------------------------------------------------------
done
var_invalid=yes
while [[ $var_invalid = yes ]]
do
echo "Do you want insert another row"
echo "1)Yes"
echo "2)No"
read  var
if [[ $var = Yes || (($var = 1)) ]]; then
i_want_continue=yes
var_invalid=no
continue
elif [[ $var = No || (($var = 2)) ]]; then
i_want_continue=No
var_invalid=no
break
else
echo "Enter valid input"
var_invalid=yes
fi
done
done
orderRowsByPK "$1" "$tab_name"
}
#-----------------------------------------------------------------------------------------Main Start The program--------------------------------------------------------------------------------------------------------------------
echo "Welcome! Your beautiful program has been started!, $USER"
#المشكلة اني عايز اعمل انشاء للفولدر اللى هيحتوي كل الداتا بيز بعد كده وخايف يكون هو عامل فولدر بنفس الاسم او انا بالفعل عملتله الفولدر ده وراح حرك #الفولدر من مكانه بتاع الداتا بيز فجيه يفتح #البرنامج تاني فالبرنامج بيتاكد ان ده مش اول مره يرن على الماشين ديه ويدور على فولدر الداتا بيز يةقم ميلقهوش #فبرنامجي يفهم ان كده هو اول مره يشتغل رغم انه اشتغل قبل كده بس المستخدم #حرك الفولدر من مكانه 
finger_print_exist_1=false
for i in `ls -a`
do 
if [[ $i = ".my_finger_print_on_your_device_1" ]]; then
finger_print_exist_1=true
break
else
continue
fi
done
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
database_dir_found=false

for i in `ls -a`
do
if [[ $i = "database" ]]; then
database_dir_found=true
#هنا انا متاكد بنسبة كبيرة ان الفولدر ده بتاعي بس خايف يكون هوه حرك الفولدر ده من مكانه واضاف فولدر
break
fi
done 

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
finger_print_exist_2=false
if [[ $database_dir_found = true ]]; then
for i in `ls -a ./database`
do 
#لو لقيتها يبقي الملف ده بتاعي ولو ملقتهاش يبقي الملف ده بتاعه هوه ومسميه databas
if [[ $i = ".my_finger_print_on_your_device_2" ]]; then
finger_print_exist_2=true
break
else
continue
fi
done
fi
#---------------------------------------------------------------------------------------------------------------
#user remove finger_print_1 and data base exist
if [[ $finger_print_exist_1 = false &&  $database_dir_found = true  && $finger_print_exist_2 = true ]]; then
echo "Hi $USER, I think you remove my_finger_print_on_your_device_1 file! Please do not remove it as it help me!"
touch ./.my_finger_print_on_your_device_1
finger_print_exist_1=true
#----------------------------------------------------------------------------------------------------------------

elif [[ $finger_print_exist_1 = true && $database_dir_found = false && $finger_print_exist_2 = false ]]; then
echo "I think you remove my directory database or you change the directory of database directory and make directory called database in $PWD"
select  option  in "remove DB directory" "move datebase directory from its location and make anothe one in same location with same name"
do
case $REPLY in
1)
mkdir ./database
touch ./database/.my_finger_print_on_your_device_2
finger_print_exist_2=true
database_dir_found=true
break
;;
2)
echo "Please return the directory database to $PWD location and before that move the database directory you create it to another place"
database_dir_found=false
break
;;
*)
echo "Please Enter Valid Choice"
;;
esac
done


#--------------------------------------------------------------------------------------------------------------------------------------------------------------------
elif [[ $finger_print_exist_1 = true && $database_dir_found = true && $finger_print_exist_2 = true ]]; then
echo "Welcom again $USER !"
#-------------------------------------------------------------------------------------------------------------------------------------

elif [[ $finger_print_exist_1 = false && $database_dir_found = true && $finger_print_exist_2 = false ]]; then
echo "My be it is the first time using my program or mr may be you delete my file my_finger_print_on_your_device_2 my_finger_print_on_your_device_1"
echo "I need to create directory caleed database in but i found one$PWD"
select  option  in "create db in exist dir" "move database dir to another location" 
do
case $REPLY in
1)
touch ./.my_finger_print_on_your_device_1
touch ./database/.my_finger_print_on_your_device_2
finger_print_exist_2=true
break
;;
2)
echo "move existing database dir to another location or rename so i can make my database dir"
touch ./.my_finger_print_on_your_device_1
finger_print_exist_2=false
break
;;
*)
echo "Please Enter Valid Choice"
;;
esac
done
#----------------------------------------------------------------------------------------------------------------

elif [[ $finger_print_exist_1 = false && $database_dir_found = false && $finger_print_exist_2 = false ]]; then
echo "Welcome, $USER I know that is your first time use my program"
mkdir ./database
touch ./.my_finger_print_on_your_device_1
touch ./database/.my_finger_print_on_your_device_2
finger_print_exist_1=true
database_dir_found=true
finger_print_exist_2=true


#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

elif [[ $finger_print_exist_1 = true &&  $database_dir_found = true  && $finger_print_exist_2 = false  ]]; then
echo "I think you remove my file my_finger_print_on_your_device_2 or you change the directory of database directory and make directory called database in $PWD"
select  option  in "delete my file my finger print on your device_2" "move datebase directory from its location and make anothe one in same location with same_name"
do
case $REPLY in
1)
touch ./database/.my_finger_print_on_your_device_2
finger_print_exist_2=true
break
;;
2)
echo "Please return the directory database to $PWD location and before that move the database directory you create it to another place"
finger_print_exist_2=false
break
;;
*)
echo "Please Enter Valid Choice"
;;
esac
done
fi 

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if [[ $finger_print_exist_1 = true &&  $database_dir_found = true  && $finger_print_exist_2 = true  ]]; then
echo "Please Enter the number of your choice"
select choice in "Create Database" "list Databases" "Delete Database" "connect to database" "Exit" 
do
case $REPLY in
1)
var=1
while [[ $var = 1 ]]
do
read -p "Enter the database name :" dbname
# validate db name
validateDBobjectName $dbname
var=$?
if [[ $var = 1 ]]; then
continue
fi 
cd ./database	
if [ -e "$dbname" ]
then
 echo "Database already exist"
 #cd ../DBMS_bash_project
 cd ../	
else
#cd ./database	
mkdir "$dbname"
echo "Database created successfully"
 cd ../	

fi
done 
;;


2)
cd ./database
# -p is to add / to directories to grep them
ls -p | grep /
cd ../
;;

3)
read -p "Enter the database name :" dbname

cd ./database
if [ -e "$dbname" ]
 #cd ../DBMS_bash_project	
then
#cd ../database
rm -r "$dbname"
echo "Database deleted successfully"
cd ../
else
echo "There is no database with this name"
ls -F  | grep -i "/$" 
 cd ../	
fi	
;;

4)
read -p "Enter the database name :" dbname
cd ./database

if [ -e "$dbname" ]
then
 echo "Connection to ${dbname} Succeded"
 echo "Enter the number of your operation"
 select action in "Create table" "List tables" "Drop table" "Insert table" "Select from table" "Delete from table" "Update table" "Back"
 do 
case $REPLY in
1)
#----------------------------------------------------------------------------------create table call---------------------------------------------------------------------------------------------------------------------------- 
createTable  "$dbname"
;;
2)
#----------------------------------------------------------------------------------List table call-----------------------------------------------------------------------------------------------------------------------------
list_table "$dbname"
;;
3)
#-----------------------------------------------------------------------------------Drop table call--------------------------------------------------------------------------------------------------
drop_table "$dbname"
;;
4)
#----------------------------------------------------------------------------------insert table call----------------------------------------------------------------------------------------------------------------------------
insertInTable  "$dbname"
#orderRowsByPK "$dbname"

;;
5)
#----------------------------------------------------------------------------------select table call----------------------------------------------------------------------------------------------------------------------------
selectFromTable  "$dbname"
;;
6)
#----------------------------------------------------------------------------------select table call----------------------------------------------------------------------------------------------------------------------------
deleteFromTable  "$dbname"
;;
7)
updateTable "$dbname"
;;
esac
done


else
echo "There is no database with this name, I think you mean one of these files"
ls -F  | grep -i "/$" 
cd ../
fi      
;;

5)
break
;;

*)
echo "Please Enter Valid Choice"
;;
esac
done 
fi
