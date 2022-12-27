#!/bin/bash

if [ "$DATABASE" = "postgres" ]
then
    echo "Waiting for postgres..."

    while ! nc -z ${POSTGRES_HOST} ${POSTGRES_PORT}; do
      sleep 0.1
    done

    echo "PostgreSQL started"
fi

python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py collectstatic --no-input --clear

python3 manage.py loaddata fixtures/default_scan_engines.yaml --app scanEngine.EngineType
#Load Default keywords
python3 manage.py loaddata fixtures/default_keywords.yaml --app scanEngine.InterestingLookupModel
#Load Default External Tools
python3 manage.py loaddata fixtures/external_tools.yaml --app scanEngine.InstalledExternalTool

# update whatportis
yes | whatportis --update

# clone dirsearch default wordlist
if [ ! -d "/usr/src/wordlist" ]
then
  echo "Making Wordlist directory"
  mkdir /usr/src/wordlist
fi

if [ ! -f "/usr/src/wordlist/" ]
then
  echo "Downloading Default Directory Bruteforce Wordlist"
  wget https://raw.githubusercontent.com/maurosoria/dirsearch/master/db/dicc.txt -O /usr/src/wordlist/dicc.txt
fi

# check if default wordlist for amass exists
if [ ! -f /usr/src/wordlist/deepmagic.com-prefixes-top50000.txt ];
then
  echo "Downloading Deepmagic top 50000 Wordlist"
  wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/deepmagic.com-prefixes-top50000.txt -O /usr/src/wordlist/deepmagic.com-prefixes-top50000.txt
fi


# clone Sublist3r
if [ ! -d "/usr/src/github/Sublist3r" ]
then
  echo "Cloning Sublist3r"
  git clone https://github.com/aboul3la/Sublist3r /usr/src/github/Sublist3r
fi

python3 -m pip install -r /usr/src/github/Sublist3r/requirements.txt

# clone OneForAll
if [ ! -d "/usr/src/github/OneForAll" ]
then
  echo "Cloning OneForAll"
  git clone https://github.com/shmilylty/OneForAll /usr/src/github/OneForAll
fi

python3 -m pip install -r /usr/src/github/OneForAll/requirements.txt

# clone eyewitness
if [ ! -d "/usr/src/github/EyeWitness" ]
then
  echo "Cloning EyeWitness"
  git clone https://github.com/FortyNorthSecurity/EyeWitness /usr/src/github/EyeWitness
  # pip install -r /usr/src/github/Eyewitness/requirements.txt
fi

# clone theHarvester
if [ ! -d "/usr/src/github/theHarvester" ]
then
  echo "Cloning theHarvester"
  git clone https://github.com/laramies/theHarvester /usr/src/github/theHarvester
fi
python3 -m pip install -r /usr/src/github/theHarvester/requirements/base.txt

# clone pwndb
if [ ! -d "/usr/src/github/pwndb" ]
then
  echo "Cloning pwndb"
  git clone https://github.com/davidtavarez/pwndb /usr/src/github/pwndb
fi

# clone dnsvalidator
if [ ! -d "/usr/src/github/dnsvalidator" ]
then
  echo "Cloning dnsvalidator"
  git clone https://github.com/vortexau/dnsvalidator /usr/src/github/dnsvalidator
fi

python3 -m pip install /usr/src/github/dnsvalidator/
ln -s /usr/local/bin/dnsvalidator /usr/bin/dnsvalidator


if [ ! -d "/usr/src/github/urless" ]
then
  echo "Cloning urless"
  git clone https://github.com/xnl-h4ck3r/urless /usr/src/github/urless
fi
python3 -m pip install /usr/src/github/urless

# install gf patterns
if [ ! -d "/root/Gf-Patterns" ];
then
  echo "Installing GF Patterns"
  mkdir ~/.gf
  cp -r $GOPATH/src/github.com/tomnomnom/gf/examples/*.json ~/.gf
  git clone https://github.com/1ndianl33t/Gf-Patterns ~/Gf-Patterns
  mv ~/Gf-Patterns/*.json ~/.gf
fi

# store scan_results
if [ ! -d "/usr/src/scan_results" ]
then
  mkdir /usr/src/scan_results
fi

# test tools, required for configuration
naabu && subfinder && amass

nuclei

#if [ ! -d "/root/nuclei-templates/geeknik_nuclei_templates" ];
#then
#  echo "Installing Geeknik Nuclei templates"
#  git clone https://github.com/geeknik/the-nuclei-templates.git ~/nuclei-templates/geeknik_nuclei_templates
#else
#  echo "Removing old Geeknik Nuclei templates and updating new one"
#  rm -rf ~/nuclei-templates/geeknik_nuclei_templates
#  git clone https://github.com/geeknik/the-nuclei-templates.git ~/nuclei-templates/geeknik_nuclei_templates
#fi

#if [ ! -d "/root/nuclei-templates/misc_nuclei_templates" ];
#then
#  echo "Installing custom Nuclei templates"
#  git clone https://github.com/NightRang3r/misc_nuclei_templates.git ~/nuclei-templates/misc_nuclei_templates
#else
#  echo "Removing old custom Nuclei templates and updating new one"
#  rm -rf ~/nuclei-templates/misc_nuclei_templates
#  git clone https://github.com/NightRang3r/misc_nuclei_templates.git ~/nuclei-templates/misc_nuclei_templates
#fi

if [ ! -d "/root/fuzzing-templates" ];
then
  echo "Installing Nuclei fuzzing templates"
  git clone https://github.com/projectdiscovery/fuzzing-templates.git ~/fuzzing-templates
else
  echo "Removing old custom Nuclei templates and updating new one"
  rm -rf ~/fuzzing-templates
  git clone https://github.com/projectdiscovery/fuzzing-templates.git ~/fuzzing-templates
fi

#cent init
#cent --config /usr/src/app/tools/cent.yaml -p /root/nuclei-templates/cent-templates -k

if [ ! -f ~/nuclei-templates/ssrf_nagli.yaml ];
then
  echo "Downloading custom nuclei templates"
  wget https://raw.githubusercontent.com/NagliNagli/BountyTricks/main/ssrf.yaml -O ~/nuclei-templates/ssrf_nagli.yaml
fi

if [ ! -f ~/nuclei-templates/mobileiron-log4j-rce.yaml ];
then
  echo "Downloading custom nuclei templates"
  wget https://raw.githubusercontent.com/NightRang3r/misc_nuclei_templates/main/mobileiron-log4j-rce.yaml -O ~/nuclei-templates/mobileiron-log4j-rce.yaml
fi

if [ ! -f ~/nuclei-templates/tableau-log4j-rce.yaml ];
then
  echo "Downloading custom nuclei templates"
  wget https://raw.githubusercontent.com/NightRang3r/misc_nuclei_templates/main/tableau-log4j-rce.yaml -O ~/nuclei-templates/tableau-log4j-rce.yaml
fi

if [ ! -f ~/nuclei-templates/vmware-horizon-log4j-rce.yaml ];
then
  echo "Downloading custom nuclei templates"
  wget https://raw.githubusercontent.com/NightRang3r/misc_nuclei_templates/main/vmware-horizon-log4j-rce.yaml -O ~/nuclei-templates/vmware-horizon-log4j-rce.yaml
fi

if [ ! -f ~/nuclei-templates/vmware-workspace-one-log4j-rce.yaml ];
then
  echo "Downloading custom nuclei templates"
  wget https://raw.githubusercontent.com/NightRang3r/misc_nuclei_templates/main/vmware-workspace-one-log4j-rce.yaml -O ~/nuclei-templates/vmware-workspace-one-log4j-rce.yaml
fi


#if [ ! -f ~/nuclei-templates/ssrf_nagli.yaml ];
#then
#  echo "Downloading ssrf_nagli for Nuclei"
#  wget https://raw.githubusercontent.com/NagliNagli/BountyTricks/main/ssrf.yaml -O ~/nuclei-templates/ssrf_nagli.yaml
#fi

mkdir -p /root/.config/nuclei/
touch /root/.config/nuclei/.nuclei-ignore

if [ ! -d "/usr/src/github/CMSeeK" ]
then
  echo "Cloning CMSeeK"
  git clone https://github.com/Tuhinshubhra/CMSeeK /usr/src/github/CMSeeK
fi
pip install -r /usr/src/github/CMSeeK/requirements.txt

if [ ! -d "/usr/src/github/waymore" ]
then
  echo "Cloning waymore..."
  git clone https://github.com/xnl-h4ck3r/waymore /usr/src/github/waymore
fi
python3 -m pip install -r /usr/src/github/waymore/requirements.txt

if [ ! -d "/usr/src/github/SubDomainizer" ]
then
  echo "Cloning SubDomainizer"
  git clone https://github.com/nsonaniya2010/SubDomainizer /usr/src/github/SubDomainizer
fi
python3 -m pip install -r /usr/src/github/SubDomainizer/requirements.txt

#if [ ! -d "/usr/src/github/massdns" ]
#then
#  echo "Cloning massdns"
#  git clone https://github.com/blechschmidt/massdns.git /usr/src/github/massdns
#fi

#cd /usr/src/github/massdns && make && make install


exec "$@"

# httpx seems to have issue, use alias instead!!!
echo 'alias httpx="/go/bin/httpx"' >> ~/.bashrc
