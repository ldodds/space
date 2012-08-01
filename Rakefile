require 'rubygems'
require 'rake'
require 'rake/clean'
require 'pho'

require 'fileutils'

BASE_DIR="/home/ldodds/data/space"

NSSDC_DIR="#{BASE_DIR}/nssdc"
NSSDC_CACHE_DIR="#{NSSDC_DIR}/cache"
NSSDC_DATA_DIR="#{NSSDC_DIR}/data"

APOLLO_DIR="#{BASE_DIR}/apollo"
APOLLO_CACHE_DIR="#{APOLLO_DIR}/cache"
APOLLO_DATA_DIR="#{APOLLO_DIR}/data"

STATIC_DATA_DIR="etc/static"

CLEAN.include ["#{NSSDC_DATA_DIR}/*.rdf", "#{NSSDC_DATA_DIR}/*.ok", "#{NSSDC_DATA_DIR}/*.fail", 
               "#{APOLLO_DATA_DIR}/*.rdf", "#{APOLLO_DATA_DIR}/*.ok", "#{APOLLO_DATA_DIR}/*.fail", 
               "#{STATIC_DATA_DIR}/*.ok", "#{STATIC_DATA_DIR}/*.fail"]

task :cache_spacecraft do
  sh %{ruby bin/nssdc-cache.rb #{NSSDC_CACHE_DIR}}end

task :spacecraft => [:cache_spacecraft, :convert_spacecraft_batch]

#Creates one file per craft
task :convert_spacecraft do
  sh %{ruby bin/nssdc-spacecraft.rb #{NSSDC_CACHE_DIR} #{NSSDC_DATA_DIR} }  
end

#Batches for faster upload
task :convert_spacecraft_batch do
  sh %{ruby bin/nssdc-spacecraft-batch.rb #{NSSDC_CACHE_DIR} #{NSSDC_DATA_DIR} }  
end

task :upload_spacecraft do
  collection = Pho::RDFCollection.new(STORE, NSSDC_DATA_DIR)
  puts "Uploading spacecraft"
  collection.store()
  puts collection.summary()end

task :apollo do
  sh %{ruby bin/apollo-data.rb #{APOLLO_CACHE_DIR} #{APOLLO_DATA_DIR} }  
end

task :convert => [:spacecraft, :apollo]

#Convert to ntriples  
task :ntriples do
  Dir.glob("#{APOLLO_DATA_DIR}/*.rdf").each do |src|
    sh %{rapper -o ntriples #{src} >data/#{File.basename(src, ".rdf")}.nt}
  end
  Dir.glob("#{NSSDC_DATA_DIR}/*.rdf").each do |src|
    sh %{rapper -o ntriples #{src} >data/#{File.basename(src, ".rdf")}.nt}
  end  
  Dir.glob("#{STATIC_DATA_DIR}/*.rdf").each do |src|
    sh %{rapper -o ntriples #{src} >data/#{File.basename(src, ".rdf")}.nt}
  end
  FileUtils.cp("#{STATIC_DATA_DIR}/dbpedia-links.nt", "data/dbpedia-links.nt")
end

task :package do
  sh %{gzip data/*} 
end

task :publish => [:cache_spacecraft, :convert, :ntriples, :package]  
