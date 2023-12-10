#! /bin/bash
# welcome to my user and mention his/her user name
#--------------------------------------------------------------------------------------------------------------------You must enter number only---------------------------------------------------------------
function ValidateNumirecInput (){
if [[ $1 = +([0-9]) ]]
then
return 0
else
echo "Please Enter numbers only"
return 1
fi
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function validateDBobjectName (){
if [[ $1 =~ ^[A-Za-z]+ ]]; then
return 0
else
echo not valid name, do not start with number or special charachter.
return 1 
fi
}

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
if [[ -f "./"$1"/"$tbname"" ]]
then
echo "Table already exist"
var=1
continue	
else
touch ./"$1"/"$tbname"
touch ./"$1"/"$tbname.metadata"	
echo "Table created successfully"
tablecreated=true
var=0

fi
done 
#------------------------------------------------------------------------------------------------------------------
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


#------------------------------------------------if number of columns =1 do not ask him about number of pk column number and set it to 1 -----------------------------------------------------
if [[ $col_num = 1 ]]; then
echo $col_num
PK_col_num=1
fi
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
var=1
while (( $var == 1 && $col_num != 1 ))
do
read -p "Enter number of PK col :" PK_col_num
ValidateNumirecInput $PK_col_num
var=$?
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if [[ $PK_col_num > $col_num ]]; then
var=1
echo "Please Enter number betwen or equal to 1 and ${col_num}"
continue
fi
if [[ $var = 1 ]]; then
continue
fi
done


 #--------------------------------------take data from user will start know-----------------------------------------------------------------------------------
for (( i=0; i< $col_num ; i++ ))
do
  #--------------------------------------------------column name---------------------------------------------------------
  read -p "Enter the name of column $(($i+1)) :" col_name
  validateDBobjectName "$col_name"
  var=$?
  if [[ $var = 1 ]]; then
  ((i--))
  continue
  fi
  
  #--------------------------------------------------DataType---------------------------------------------------------
  
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
  
  #---------------------------------------------------null or not null -------------------------------------------------
  

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
  fi
    #---------------------------------------------------push my variable into table and metadata-------------------------------------------------
    #echo $PWD
    echo "${col_name}::${col_type}::${col_null}" >> ../database/"$1"/"${tbname}.metadata"
    if (( $i == (($col_num-1)) )); then
    echo -n "${col_name}" >> ../database/"$1"/"$tbname"
    else
    echo -n "${col_name}::" >> ../database/"$1"/"$tbname"
    fi
done
fi
}


#---------------------------------------------------------------------------------------------------------------------
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
#--------------------------------------------------------------------------------------------------------------
database_dir_found=false

for i in `ls ..`
do
if [[ $i = "database" ]]; then
database_dir_found=true
#هنا انا متاكد بنسبة كبيرة ان الفولدر ده بتاعي بس خايف يكون هوه حرك الفولدر ده من مكانه واضاف فولدر
break
fi
done 

#--------------------------------------------------------------------------------------------------------------
finger_print_exist_2=false
if [[ $database_dir_found = true ]]; then
for i in `ls ../database`
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
cd ..
echo "I think you remove my directory database or you change the directory of database directory and make directory called database in $PWD"
cd ./DBMS_bash_project
select  option  in "remove DB directory" "move datebase directory from its location and make anothe one in same location with same name"
do
case $REPLY in
1)
mkdir ../database
touch ../database/my_finger_print_on_your_device_2
finger_print_exist_2=true
database_dir_found=true
break
;;
2)
cd ..
echo "Please return the directory database to $PWD location and before that move the database directory you create it to another place"
cd ./DBMS_bash_project
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
cd ..
echo "I need to create directory caleed database in but i found one$PWD"
cd ./DBMS_bash_project
select  option  in "create db in exist dir" "move database dir to another location" 
do
case $REPLY in
1)
touch ./my_finger_print_on_your_device_1
touch ../database/my_finger_print_on_your_device_2
finger_print_exist_2=true
break
;;
2)
cd ..
echo "move existing database dir to another location or rename so i can make my database dir"
cd ./DBMS_bash_project
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
mkdir ../database
touch ./my_finger_print_on_your_device_1
touch ../database/my_finger_print_on_your_device_2
finger_print_exist_1=true
database_dir_found=true
finger_print_exist_2=true


#---------------------------------------------------------------------------------------------------------------

elif [[ $finger_print_exist_1 = true &&  $database_dir_found = true  && $finger_print_exist_2 = false  ]]; then

cd ..
echo "I think you remove my file my_finger_print_on_your_device_2 or you change the directory of database directory and make directory called database in $PWD"
cd ./DBMS_bash_project
select  option  in "delete my file my finger print on your device_2" "move datebase directory from its location and make anothe one in same location with same_name"
do
case $REPLY in
1)
touch ../database/my_finger_print_on_your_device_2
finger_print_exist_2=true
break
;;
2)
cd ..
echo "Please return the directory database to $PWD location and before that move the database directory you create it to another place"
cd ./DBMS_bash_project
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
echo "Plese Enter the number of your choice"

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
cd ../database	
if [ -e "$dbname" ]
then
 echo "Database already exist"
 cd ../DBMS_bash_project	
else
cd ../database	
mkdir "$dbname"
echo "Database created successfully"
 cd ../DBMS_bash_project	
fi
done 
;;


2)
cd ../database
# -p is to add / to directories to grep them
ls -p | grep /
;;

3)
read -p "Enter the database name :" dbname

cd ../database
if [ -e "$dbname" ]
 cd ../DBMS_bash_project	
then
cd ../database
rm -r "$dbname"
else
echo "There is no database with this name"
ls -F ../database | grep -i "/$" 
 cd ../DBMS_bash_project	
fi	
;;

4)
read -p "Enter the database name :" dbname

cd ../database

if [ -e "$dbname" ]
then
 echo "Connection to ${dbname} Succeded"
 echo "Enter the number of your operation"
 select action in "Create table" "List tables" "Drop table" "Insert table" "Select from table" "Delete from table" "Update table" "Back"
 do 
case $REPLY in
1)
createTable  "$dbname"
esac
done


else
echo "There is no database with this name, I think you mean one of these files"
ls -F ../database | grep -i "/$" 
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

