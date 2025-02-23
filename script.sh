#!/bin/bash

REGION=$1
aws ec2 describe-vpcs --region ${REGION} | jq ".Vpcs[].VpcId" -r

#!/bin/bash

awd --version 2>/dev/null
if [$? -eq 0]; then
    REGION=$1
    aws ec2 describe-vpcs --region ${REGION} | jq ".Vpcs[].VpcId" -r
else
    echo "Incorrect Command"
fi

#!/bin/bash
if [ $# -gt 0 ]; then
    aws --version
    if [ $? -eq 0 ]; then
        REGIONS=$@
        for REGION in ${REGIONS}; do
            aws ec2 describe-vpcs --region ${REGION} | jq ".Vpcs[].VpcId" -r
            echo "-----------------------------"
        done
    else
        echo "Incorrect command"
    fi
else
    echo "Enter some valid regions"
fi

#!/bin/bash

for i in {1..100}; do
    if [ $((i % 2)) -eq 0 ]; then
        echo "$i is even number"
    fi
done

#!/bin/bash
while true; do
    curl www.google.com | grep -i google
    sleep 1
done

#!/bin/bash
if [ $# -gt 0 ]; then
    for USER in $@; do
        echo $USER
        # if [[ $USER =~ ^[a-zA-Z]+$ ]]; then
        if [[ $USER =~ ^[a-z][a-z][a-z][0-9][0-9][0-9]$ ]]; then
            // now username should be like aaa123
            EXISITING_USER=$(cat /etc/passwd | grep -i -w $USER | cut -d ":" -f 1)
            if [ "${USER}" = "${EXISITING_USER}" ]; then
                echo "$USER username already exists in the machine, Please enter any other username"
            else
                echo "Let's create a new username for $USER"
                sudo useradd -m $USER --shell /bin/bash
                SPEC=$(echo '!@#$%^&*()_+=-' | fold -w1 | shuf | head -1)
                PASSWORD="Tendrix@${RANDOM}${SPEC}"
                echo "$USER:$PASSWORD" | sudo chpasswd
                echo "The temporary passwrod for the $USER is ${PASSWORD}"
                passwd -e $USER
            fi
        else
            echo "Username must contain alphabets"
        fi
    done
else
    echo "please enter valid username"
fi

#!/bin/bash
aws_regions=(us-east-1 us-east-2 us-west-1 hyd-india-1)
for region in "${aws_regions[@]}"; do
    echo "Getting vpc's in $region .. "
    vpc_list=$(aws ec2 describe-vpc --region "$region" | jq -r .Vpcs[].VpcId)
    vpc_arr=(${vpc_list[@]})

    if [ ${vpc_arr[@]} -gt 0 ]; then
        for vpc in "${vpc_list[@]}"; do
            echo "The Vpc id is : $vpc"
        done
        echo "########"
    else
        echo "Invalid Region..!"
        echo "########"
        echo "Breaking at region $region"
        echo "########"
        # break
        # exit 99
        continue
    fi
done

#!/bin/bash

delete_vols() {
    # Fetch all volumes
    vols=$(aws ec2 describe-volumes | jq ".Volumes[].VolumeId" -r)

    for vol in $vols; do
        # Fetch volume details
        volume_info=$(aws ec2 describe-volumes --volume-ids $vol)
        size=$(echo "$volume_info" | jq ".Volumes[].Size")
        state=$(echo "$volume_info" | jq ".Volumes[].State" -r)

        # Check volume size and state
        if [ "$state" == "in-use" ]; then
            echo "$vol is attached to an instance. Skipping deletion."
        elif [ "$size" -gt 5 ]; then
            echo "$vol is larger than 5GB. Skipping deletion."
        else
            echo "Deleting Volume $vol"
            aws ec2 delete-volume --volume-id $vol
        fi
    done
}

# Call the function
delete_vols



#!/bin/bash
function subnets {
    echo "************************************************************"
    echo "**Getting SUBNETS Info VPC $VPC in region $REGION**"
    echo "************************************************************"
    aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC" --region $REGION | jq ".Subnets[].SubnetId"
    echo "---------------------------------------------"
}

function sg {
    echo "********************************************************************"
    echo "**Getting Security Group Info VPC $VPC in region $REGION**"
    echo "********************************************************************"
    aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC" --region $REGION | jq ".SecurityGroups[].GroupName"
    echo "---------------------------------------------"
}

vpcs() {
    for REGION in $@; do
        echo "Getting VPC List For Regions $REGION..."
        vpcs=$(aws ec2 describe-vpcs --region "${REGION}" | jq ".Vpcs[].VpcId" | tr -d '"')
        echo $vpcs
        echo "--------------------------------------------------"
        for VPC in $vpcs; do
            subnets $VPC
             sg $VPC
        done
        # for VPC in $vpcs; do
        #     sg $VPC
        # done
    done
}

vpcs $@

