#!/bin/bash

echo "[TASK 1] Change private key permission"
chmod 400 ~/.ssh/id_rsa

echo "[TASK 2] Pull cluster connection token"
scp -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no root@172.16.16.201:/joincluster.sh /joincluster.sh

echo "[Task 3] Join the cluster"
bash /joincluster.sh
