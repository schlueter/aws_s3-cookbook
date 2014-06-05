require 'aws/s3'
include AWS::S3


def whyrun_supported?
  true
end

def setup_connection
    AWS::S3::Base.establish_connection!(
        access_key_id:     node[:aws][:access_key_id],
        secret_access_key: node[:aws][:secret_access_key]
    )
end

def get_object(name, bucket)
    S3Object.find(name, bucket)
end

action :create do

    # aws_s3_object :create requires a file or content to use as data for the new object
    if not @new_resource.file and not @new_resource.content
        Chef::Log.error(
            "aws_s3_object[#{@new_resource.name}] cannot be created without a file or content attribute."
        )
        raise
    end

    setup_connection
    S3Object.store(
        @new_resource.name,
        @new_resource.content or open(@new_resource.file),
        @new_resource.bucket
    )

    if @new_resource.make_public
        object = get_object(@new_resource.name, @new_resource.bucket)
        object.grant_torrent_access
    end

    new_resource.updated_by_last_action(true)
end

action :delete do
    setup_connection

    object = get_object(@new_resource.name, @new_resource.bucket)
    object.delete

    new_resource.updated_by_last_action(true)
end

action :retrieve do

    # :retrieve requires a file to retrieve to
    if not @new_resource.file
        Chef::Log.error(
            "aws_s3_object[#{@new_resource.name}] cannot be retireved without a file attribute."
        )
        raise
    end
    setup_connection

    # Find object in specified bucket
    object = get_object(@new_resource.name, @new_resource.bucket)

    # Read object in chunks to allow for better performance with larger objects
    File.open(@new_resource.file, 'wb') do |file|
        object.read do |chunk|
            file.write(chunk)
        end
    end

    new_resource.updated_by_last_action(false)
end
