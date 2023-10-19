#!/bin/bash

if [ -f output.txt ]; then
    rm output.txt
fi

JOHN_BINS_PATH=/home/nico/src/john/run
JOHN=$JOHN_BINS_PATH/john
UNSHADOW=$JOHN_BINS_PATH/unshadow

STRATEGIES=(
    "--incremental=digits --min-length=3 --max-length=7"
    "--incremental=ascii --min-length=3 --max-length=7"
    "--wordlist=strategy_dictionaries/500_pwds.txt"
    "--wordlist=strategy_dictionaries/rockyou.txt"
    "--wordlist=strategy_dictionaries/rockyou.txt --mask=\"?w?d?d\""
)

HASHES=("md5crypt" "sha512crypt")

for dataset_folder in $(ls passwords); do
    echo "+++++++++++++++++++++++++++++ Processing $dataset_folder dataset +++++++++++++++++++++++++++++" $'\n' | tee -a output.txt
    for dataset in $(ls passwords/${dataset_folder}); do
        for hash in "${HASHES[@]}"; do
            echo "---------------------------- $hash $dataset_folder/$dataset ----------------------------" | tee -a output.txt

            for strategy in "${STRATEGIES[@]}"; do
                echo $'\n' "• running strategy: $strategy" | tee -a output.txt

                # Create users and set passwords
                for i in {1..100}; do
                    # Create user
                    sudo useradd "john_$i"

                    # Get password from file
                    PASSWORD=$(sed -n "${i}p" "passwords/$dataset_folder/$dataset")
                    # Hash the password with the corresponding hashing algorithm
                    PASSWORD_HASHED=$(mkpasswd -m $hash $PASSWORD)

                    # Set the password
                    echo "john_${i}:${PASSWORD_HASHED}" | sudo chpasswd --encrypted
                done
                echo "    Users created and passwords set."

                # get only the newly created hashed passwords
                sudo grep "^john_" /etc/passwd > /tmp/john_passwd
                sudo grep "^john_" /etc/shadow > /tmp/john_shadow
                $UNSHADOW /tmp/john_passwd /tmp/john_shadow > /tmp/john_unshadow


                # execute john strategies
                time ($JOHN --format=$hash --max-run-time=300 $strategy /tmp/john_unshadow 2> /dev/null) 2>> output.txt
                $JOHN --show /tmp/john_unshadow >> output.txt

                # delete users
                for i in {1..100}; do
                    sudo userdel john_$i
                done
                echo "    users deleted"
            done

        done
    done
done
