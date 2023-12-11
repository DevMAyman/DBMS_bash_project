#! /bin/bash
# welcome to my user and mention his/her user name
#--------------------------------------------------------------------------------------------------------------------You must enter number only---------------------------------------------------------------------
function ValidateNumirecInput (){
if [[ $1 = +([0-9]) ]]
then
return 0
else
echo "Please Enter numbers only"
return 1
fi
}
function ValidateDTNumirecInput (){
if [[ $1 = *([0-9]) ]]
then
echo "Data type validate successfully"
return 0
else
echo "Please Enter numbers only"
return 1
fi
}
#-------------------------------------------------------------------------------------------------------check uniqness--------------------------------------------------------------------------------------------------------------
##check_uniqueness $1 $tab_name $col_value $var
function check_uniqueness (){
PK_field=$(awk  -F '::' -v col_num=$4 -v col_val=$3 '{if ($col_value == $"$col_num"){print 1; exit}}' ./"$1"/"$2")
return $PK_fields
}
#-------------------------------------------------------------------------------------------------------NULL or Not NULL-------------------------------------------------------------------------------------------------------------
# parameters : $1 $tab_name $c $col_value
function chechNull (){
((line_number_in_metadatafile=$3+1))
is_null=$(head -$line_number_in_metadatafile ./"$1"/"$2.metadata" | tail -1 | awk -F '::' '{print $3}') #$3 is the third field (null,not_null)
if [[ $is_null = not_null && -z "$4"    ]]; then
echo "Not ok, your column is not_null and you insert no thing"
return 1
elif [[ $is_null = null && -z "$4" ]]; then
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
dataType=$(head -$line_num ./"$1"/"$2.metadata" | tail -1 | awk -F '::' '{print $2}') #$2 is the second field (int,string)
 
if [[ $dataType = int   ]]; then 
ValidateDTNumirecInput $4  #Must be modified ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
var=$?
return $var
elif [[ $dataType = string && $4 = +([0-9])  ]]; then
echo "Please enter String"
return 1
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
rm "$tbname" "$tbname.metadata"
echo "Table deleted successfully"
cd ../
else
echo "There is no table with this name"
echo "Your tables at ${1} databse are :" 
ls -p  | grep -vE '.metadata$|/' 
cd ../
fi
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
touch ./"$1"/"$tbname.metadata"	
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
    echo "${col_name}::${col_type}::${col_null}" >> ../database/"$1"/"${tbname}.metadata"
    elif [[ $is_primary_key = yes ]]; then
    echo "${col_name}::${col_type}::${col_null}::"PK"" >> ../database/"$1"/"${tbname}.metadata"
    fi
    if (( $i == (($col_num-1)) )); then
    echo  "${col_name}" >> ../database/"$1"/"$tbname"
    else
    echo -n "${col_name}::" >> ../database/"$1"/"$tbname"
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
let num_col=$(awk -F '::' '{print NF}' ./"$1"/"$tab_name") #number of column
#echo $num_col
i_want_continue=yes
while [[ $i_want_continue = yes ]]
do
for (( c=0; c<$num_col; c++ ))
do
in_col_name=$(head -1  ./"$1"/"$tab_name" | awk -v var=$(($c+1)) -F '::' '{print $var}')
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
pk_exist=$(head -$var ./"$1"/"${tab_name}.metadata" | tail -1 | awk -F '::' '{print $4}') #number of column
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
echo -n "${col_value}::" >> ./"$1"/"$tab_name"
elif (( $c == (($num_col-1)) )); then
echo  "${col_value}" >> ./"$1"/"$tab_name"
else
echo -n "${col_value}::" >> ./"$1"/"$tab_name"
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
}
#-----------------------------------------------------------------------------------------Main Start The program--------------------------------------------------------------------------------------------------------------------
echo "Welcome! Your beautiful program has been started!, $USER"
#المشكلة اني عايز اعمل انشاء للفولدر اللى هيحتوي كل الداتا بيز بعد كده وخايف يكون هو عامل فولدر بنفس الاسم او انا بالفعل عملتله الفولدر ده وراح حرك #الفولدر من مكانه بتاع الداتا بيز فجيه يفتح #البرنامج تاني فالبرنامج بيتاكد ان ده مش اول مره يرن على الماشين ديه ويدور على فولدر الداتا بيز يةقم ميلقهوش #فبرنامجي يفهم ان كده هو اول مره يشتغل رغم انه اشتغل قبل كده بس المستخدم #حرك الفولدر من مكانه 
finger_print_exist_1=false
for i in `ls`
do 
if [[ $i = "my_finger_print_on_your_device_1" ]]; then
finger_print_exist_1=true
break
else
continue
fi
done
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
database_dir_found=false

for i in `ls`
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
for i in `ls ./database`
do 
#لو لقيتها يبقي الملف ده بتاعي ولو ملقتهاش يبقي الملف ده بتاعه هوه ومسميه databas
if [[ $i = "my_finger_print_on_your_device_2" ]]; then
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
touch ./my_finger_print_on_your_device_1
finger_print_exist_1=true
#----------------------------------------------------------------------------------------------------------------

elif [[ $finger_print_exist_1 = true && $database_dir_found = false && $finger_print_exist_2 = false ]]; then
echo "I think you remove my directory database or you change the directory of database directory and make directory called database in $PWD"
select  option  in "remove DB directory" "move datebase directory from its location and make anothe one in same location with same name"
do
case $REPLY in
1)
mkdir ./database
touch ./database/my_finger_print_on_your_device_2
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
touch ./my_finger_print_on_your_device_1
touch ./database/my_finger_print_on_your_device_2
finger_print_exist_2=true
break
;;
2)
echo "move existing database dir to another location or rename so i can make my database dir"
touch ./my_finger_print_on_your_device_1
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
touch ./my_finger_print_on_your_device_1
touch ./database/my_finger_print_on_your_device_2
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
touch ./database/my_finger_print_on_your_device_2
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

#----------------------------------------------------------------------------------------------------------------
#echo "$finger_print_exist_1"
#echo "$database_dir_found"
#echo "$finger_print_exist_2"

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
