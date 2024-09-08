# Sprimp

A script to import java spring claasses using text processing, sqlie3 and a tagging mechanism. made specifically
for someone who doesn't want to install eclipse but still wants the auto import feature

### Installation

all you have to do is to hit install.sh :) see `bashrc.sh` for more configs. if u run into problems with Set-Scalar library
I recommend visitting [It's Github Page](https://github.com/daoswald/Set-Scalar) or :
```
git clone https://github.com/daoswald/Set-Scalar
cd Set-Scalar
perl Makefile.pl
```
from there on, follow the instructions of make

## How to run it?

It's based on aliasing the usage of __sprimp.sh__. after you have it installed (run the install.sh) you can go to __$SPRIMP_HOME__
and hit the __./sprimp.sh__ manually. or just hit `${SPRIMP_HOME}/sprimp.sh` from any arbitrary directory. but just use the alias,
please :|

Suppose you have a maven project and it has a number of .java files. You want to make your 
src/main/java/some/program/package/__Special.java__ to be handled by the program. Suppose pom.xml is in __$PROJECT_DIR__:
```
cd $PROJECT_DIR
```
Then mark your .java file with `// @imp` (not a whitespace less or more!) in any line you want 
and then call the alias for sprimp (which you can set in bashrc.sh) at the pwd or any parent directories:
```
echo "// @imp" >> src/main/java/some/program/package/Special.java
```
It will then import all the classes you need **UNLESS** you import it by yourself. this is to prevent the tool from
importing classes with the same name as your current classes. for instance if you have a __Role__ class it might be mistaken
for __org.springframework.context.annotation.Role__
If you remove the `// @imp` part from your .java file, that file is no longer taken into account when scanning

Now it's time for you to see the magic. suppose you alias a command that uses this program as __sprimp__:
```
sprimp
```
And that's it!

### Shorthand
If you don't have a specific class in mind and just want all your classes to be monitored, here's a shorthand for it:
```
cd $PROJECT_DIR
find . -name "*.java" -exec echo "// @imp">> {} \;
sprimp
```

## Issue with package statement
Beware! the package statement support only goes 1 level deep at this point! that is, if you have `org.program.pack.sth` it's ok,
but as soon as you go `org.program.pack.sth.pack2` it's all phucked up!

I intend to fix this obviously, but be patient. use with caution until I patch it up!

Otherwise I have not found out about any other bugs __sofar__ , and I'd appretiate it if you'd inform me under "ezekiel2088@gmail.com" if you found anything

## Technical

Ok now if u give a $hit about how this thing is structered: the core of this 'tool' (I don't know what to call it at this point) is
a perl script - which is my 1st perl program btw, so it's not very proffesionally written - that parses a .java file and catches the
following parts:

1- 	CamelCase Words (as __big_guys__) / saved in a __Set__ datastructure

2- 	imported classes (as __already__) / saved as an __array__

3- 	full import statements (as __already__imports__)  which are corresponding to __already__. the reason they exist is bc I didn't want to look up the ones
		already imported. besideds, they might have been imported from local packages, so if I look them up, some of them (like for instance a local __Role__ class)
		might be replaced by their spring counterparts / saved as an __array__

4- 	rest of the file  (as __rest__) / saved as an __array__

After a file is parsed these information (along with a couple others) are saved in a __hash__ (the same as dictionaries with python. but more phucked up, since this
is perl...I think) and the hash is returned from the function. this hash's __big_guys__ are then iterated and if any of them does not exist in the __already__, the program
makes a connection to the local __full_class.db__ and `SELECT`s the corresponding package name (see __schema.sql__ if u care) for that bigguy. then appends it to a 
new __array__ in hash, called __new_imports__. after all the hassle is done, the program then writes the hash's arrays in the right order to $filename.imp

From this point on it's the job of __sprimp.sh__ to utilize this perl script. so what it basically does, it takes whatever .java file with `// @imp` statement in it and
prepares some variables (like for instance the package name based on the .java file's parent directories) and then goes over the entries one by one. it then feed each entry
to that perl script. onece the script is done, it replaces the original file with the newly generated .imp file and finally cleans up the mess


### TODO
- [ ] make sprimp's `last_package` go as deep as possible using the "program name" in pom.xml
- [ ] add lombok support (or maybe not, who gives a fuck, it's a one-liner u prick, do it per hand)
- [ ] add plain java support
- [ ] add support for choosing between java and spring


### Contact
Again, if u have any questions or objections, or just wanted to banther, deosn't matter. a letter from a stranger is always welcome. you can reach me out under 
"ezekiel2088@gmail.com"

if that email didn't work, reach me in telegram under `@ezekiel_2088` username

### CHEERS!
