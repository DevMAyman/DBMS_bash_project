#! /bin/bash
# welcome to my user and mention his/her user name
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
if [[ $finger_print_exist_1 = false &&  $database_dir_found = true  && $database_dir_found = true ]]; then
echo "Hi $USER, I think you remove my_finger_print_on_your_device_1 file! Please do not remove it as it help me!"
touch ./my_finger_print_on_your_device_1
finger_print_exist_1=true
fi

#----------------------------------------------------------------------------------------------------------------

if [[ $finger_print_exist_1 = true && $database_dir_found = false && $finger_print_exist_2 = false ]]; then
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
esac
done
fi

#----------------------------------------------------------------------------------------------------------------

if [[ $finger_print_exist_1 = true && $database_dir_found = true && $finger_print_exist_2 = true ]]; then
echo "Welcom again $USER !"
fi

#----------------------------------------------------------------------------------------------------------------

if [[ $finger_print_exist_1 = false && $database_dir_found = true && $finger_print_exist_2 = false ]]; then
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
esac
done
fi

#----------------------------------------------------------------------------------------------------------------

if [[ $finger_print_exist_1 = false && $database_dir_found = false && $finger_print_exist_2 = false ]]; then
echo "Welcome, $USER I know that is your first time use my program"
mkdir ../database
touch ./my_finger_print_on_your_device_1
touch ../database/my_finger_print_on_your_device_2
finger_print_exist_1=true
database_dir_found=true
finger_print_exist_2=true
fi

#---------------------------------------------------------------------------------------------------------------

if [[ $finger_print_exist_1 = true &&  $database_dir_found = true  && $finger_print_exist_2 = false  ]]; then

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
esac
done
fi 

#----------------------------------------------------------------------------------------------------------------
#echo "$finger_print_exist_1"
#echo "$database_dir_found"
#echo "$finger_print_exist_2"

if [[ $finger_print_exist_1 = true &&  $database_dir_found = true  && $finger_print_exist_2 = true  ]]; then

fi
