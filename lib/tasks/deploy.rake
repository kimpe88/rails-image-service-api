namespace :deploy do
  desc "Deploys folder to /var/www and starts unicorn server"
  task unicorn: :environment do
    path =  "/var/www/sk_instagram_api"
    FileUtils.rm_r path
    FileUtils.cp_r(Rails.root, "/var/www")
    Dir.chdir(path)
    exec "unicorn_rails -c #{path}/config/unicorn.conf.rb -D"

  end

end
