namespace :cron do
  desc "Make an active company payload"
  task :make_company_payload => :environment do
    AWS.config(
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_KEY']
    )
    
    bucket_name = ENV['AWS_STORM_BUCKET']
    file_name = 'active-companies.json'
    local_file_path = '/tmp/' + file_name

    File.open(local_file_path, 'w') do |file| 
      file.write(Company.where(active: true).to_json)
    end
    
    # Get an instance of the S3 interface.
    s3 = AWS::S3.new

    # Upload a file.
    key = File.basename(file_name)
    s3.buckets[bucket_name].objects[key].write(Pathname.new(local_file_path))
    
  end

end
