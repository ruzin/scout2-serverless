#!/bin/bash
#aws cli command to invoke the scout2 lambda function
aws lambda invoke \
--invocation-type RequestResponse \
--function-name $function_arn \
--region $region \
outputfile.txt
