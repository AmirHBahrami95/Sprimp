#!/usr/bin/sh

echo "installing perl based on your distro..."
(sudo apt update \
	&& echo 'my man(/girl) using debian! good choice!' \
	&& sudo apt install perl make git libclass-dbi-perl 2>/dev/null) \
|| \
(sudo pacman -Syy \
	&& echo 'you use arch btw!' \
	&& sudo pacman -Sy perl make git libclass-dbi-perl 2>/dev/null) \
|| \
(sudo dnf update --refresh \
	&& echo 'you,re using fedora-based? boy are u about to download half the internet' \
	&& sudo dnf groupinstall "Development Tools" "Development Libraries" \
	&& sudo dnf install perl git make libclass-dbi-perl 2>/dev/null)

# dependency
echo "installing Set::Scalar..."
git clone git@github.com:daoswald/Set-Scalar.git
cd Set-Scalar
perl Makefile.pl
make 
make test
make install

# only for current session and after installation
echo "initializing & aliasing bash and perl scripts..."
export SPRIMP_HOME="${HOME}/sprimp"
alias sprimp="${SPRIMP_HOME}/sprimp.sh"

echo "just chilling for a second, don't worry I'd be back to work in no time..."
sleep 3 # just to make sure 'make'ing  won't phuck anything up

# appending bash thingy
echo 'export SPRIMP_HOME="${HOME}/sprimp"' >> ~/.bashrc && echo 'Done.'
echo 'alias sprimp="${SPRIMP_HOME}/sprimp.sh"' >> ~/.bashrc && echo 'Done.'

mkdir -p ${SPRIMP_HOME}
chmod +x ./sprimp.sh
cp sprimp.sh ${SPRIMP_HOME}/
cp -r javimp ${SPRIMP_HOME}/
echo "enjoy sprimping!"
