#!/bin/bash
runuser -l hadoop -c "ssh-keygen -q -t rsa -N '' -f /home/hadoop/.ssh/id_rsa"
