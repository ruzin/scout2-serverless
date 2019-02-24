# -*- coding: utf-8 -*-

import os
import sys
import shutil
import os.path
import mimetypes
import boto3
from botocore.exceptions import ClientError, ParamValidationError
from AWSScout2.__main__ import main

def lambda_handler(event, context):
    cmd_args = os.environ['CMD_ARGS']
    exception_tests = os.environ['EXCEPTION_TESTS']
    report_cmd = ",--report-dir,{0}".format(os.environ['REPORT_DIR'])
    report_s3_storage_name = os.environ['REPORT_S3_STORAGE_NAME']
    project_name = os.environ['PROJECT_NAME']
    environment = os.environ['ENVIRONMENT']
    path = os.environ['REPORT_DIR']

    sys_args = cmd_args + report_cmd + exception_tests
    sys.argv = sys_args.split(",")
    shutil.rmtree(os.environ['REPORT_DIR'], ignore_errors=True)

    #Running scout2 report
    main()

    #Upload folder structure and files of scout2 report
    s3_boto_client = boto3.client('s3', region_name="eu-west-1")

    #Upload folder structure and files for scout2 report static website
    for subdir, dirs, files in os.walk(path):
        for file in files:
            full_path = os.path.join(subdir, file)
            with open(full_path, 'rb') as data:
                #assigning correct content type to css and js files
                content_type = mimetypes.guess_type(file)[0]
                try:
                    s3_boto_client.put_object(Bucket=report_s3_storage_name,Key=full_path[len(path)+1:], Body=data, ContentType=content_type)
                except ParamValidationError as e:
                    s3_boto_client.put_object(Bucket=report_s3_storage_name,Key=full_path[len(path)+1:], Body=data)

    #Upload folder structure and files as scout2 report zip archive
    src_report_file_name = "{0}_{1}".format(project_name, environment)
    shutil.make_archive(
        "/tmp/{0}".format(src_report_file_name),
        'zip',
        path,
    )
    s3_boto_client.upload_file(
        "/tmp/{0}.zip".format(src_report_file_name),
        report_s3_storage_name,
        "{0}/{1}/{2}.zip".format('report_zip_archive', environment, src_report_file_name)
    )

if __name__ == '__main__':
    lambda_handler(event=None, context=None)
