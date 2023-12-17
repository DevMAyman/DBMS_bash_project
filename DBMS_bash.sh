#! /bin/bash
. createTableFunc
. updateTable
. select_from_table
. insert_in_table
. delete_from_table
. validation_funcs
. ls_drop_table
. add_delete_column

#-----------------------------------------------------------------------------------------Main Start The program-------------------------------------------------------------
if [  ! -e "./.logs" ]; then
touch ./.logs
fi
last_field_value=1
isEmpty=$(head -1 ./.logs)
if [[ $isEmpty != "" ]]; then
db_tab_name=$(tail -1 ./.logs| cut -d':' -f 1)
db_name=$(tail -1 ./.logs| cut -d':' -f 3) 
last_field_value=$(tail -1 "./database/$db_name/$db_tab_name" | awk -F ':' '{ print $NF }')
fi
if [[ $last_field_value == "" ]]; then
sed -i '$d' ./database/"$db_name"/"$db_tab_name" 
fi
echo "Welcome! Your beautiful DBMS has been started!, $USER ❤️"
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
echo "Welcom again $USER 😉!"
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
function display_menu(){
echo ""
echo ""
echo "------------------------------Main Menu------------------------------"
echo -e "1-Create Database\n2-List Databases\n3-Delete Database\n4-Connect to Database\n5-Exit"
}
function connection_menu(){
echo ""
echo "----------------------Connected to $1 Database----------------------"
echo -e "1-Create Table\n2-List Tables\n3-Drop Table\n4-Insert Table\n5-Select from Table\n6-Delete from Table\n7-Update Table\n8-Add Column to Table\n9-Delete Column from Table\n10-Back"
}

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
dbname=$(echo "$dbname" | sed 's/ /_/g')
# validate db name
validateDBobjectName $dbname
var=$?
if [[ $var = 1 ]]; then
continue
fi 
cd ./database	
if [ -e "$dbname" ]
then
 echo "❌Database already exist❌"
 #cd ../DBMS_bash_project
 cd ../	
 display_menu
else
#cd ./database	
mkdir "$dbname"
echo "✅Database created successfully✅"
 cd ../	
display_menu
fi
done 
;;


2)
cd ./database
# -p is to add / to directories to grep them
ls -p | grep /
cd ../
display_menu
;;

3)
read -p "Enter the database name :" dbname
dbname=$(echo "$dbname" | sed 's/ /_/g')
cd ./database
if [ -e "$dbname" ]
 #cd ../DBMS_bash_project	
then
#cd ../database
rm -r "$dbname"
echo "✅Database deleted successfully✅"
cd ../
display_menu
else
echo "❌There is no database with this name, I think you mean one of these files❌"
ls -F  | grep -i "/$" 
 cd ../	
display_menu
fi	
;;

4)
read -p "Enter the database name :" dbname
dbname=$(echo "$dbname" | sed 's/ /_/g')
cd ./database

if [ -e "$dbname" ]
then
 echo "✅Connection to ${dbname} Succeded✅"
 echo "Enter the number of your operation"
 select action in "Create table" "List tables" "Drop table" "Insert table" "Select from table" "Delete from table" "Update table" "Add Column to table" "Delete column from table" "Back"
 do 
case $REPLY in
1)
#----------------------------------------------------------------------------------create table call--------------------------------------------------------- 
createTable  "$dbname"
connection_menu "$dbname"
;;
2)
#----------------------------------------------------------------------------------List table call------------------------------------------------------------
list_table "$dbname"
connection_menu "$dbname"
;;
3)
#-----------------------------------------------------------------------------------Drop table call-------------------------------------------------------------------
drop_table "$dbname"
connection_menu "$dbname"
;;
4)
#----------------------------------------------------------------------------------insert table call-----------------------------------------------------------------
insertInTable  "$dbname"
connection_menu "$dbname"
;;
5)
#----------------------------------------------------------------------------------select table call--------------------------------------------------------------
selectFromTable  "$dbname"
connection_menu "$dbname"
;;
6)
#----------------------------------------------------------------------------------select table call-----------------------------------------------------------------
deleteFromTable  "$dbname"
connection_menu  "$dbname"
;;
7)
updateTable "$dbname"
connection_menu "$dbname"
;;
8)
#----------------------------------------------------------------------------------Add Column ------------------------------------------------------------------------
addcolumn "$dbname"
connection_menu "$dbname"
;;
9)
#----------------------------------------------------------------------------------Delete Column call-----------------------------------------------------------------
deletecolumn "$dbname"
connection_menu "$dbname"
;;
#--------------------------------------------------------------------------------------Back-----------------------------------------------------------------------
10)
cd ../
display_menu
break
;;
*)
echo "❌Please Enter Valid Choice❌"
connection_menu "$dbname"
;;
esac
done


else
echo "❌There is no database with this name, I think you mean one of these files❌"
ls -F  | grep -i "/$" 
cd ../
display_menu
fi      
;;

5)
break
;;

*) 
display_menu
echo "❌Please Enter Valid Choice❌"

;;
esac
done 
fi
