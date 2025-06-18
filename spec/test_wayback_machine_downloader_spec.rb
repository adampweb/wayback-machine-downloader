require_relative './spec_helper'
require_relative '../lib/wayback_machine_downloader'


RSpec.describe WaybackMachineDownloader do

    #let(:app_instance) { WaybackMachineDownloader.new(base_url: 'https://thomaston4thofjuly.com') }
   
    before do
        @wayback_machine_downloader = WaybackMachineDownloader.new(base_url: 'https://thomaston4thofjuly.com')
    end

    

    it 'base url being set' do
        actual_base_url = @wayback_machine_downloader.base_url

        expect(actual_base_url).to eq('https://thomaston4thofjuly.com')
        expect(actual_base_url).not_to eq('https://example.com')
    end

    it 'backup name being set' do
        actual_backup_name = @wayback_machine_downloader.backup_name
        
        expect(actual_backup_name).to eq('thomaston4thofjuly.com')
        expect(actual_backup_name).not_to eq('www.example.com')
    end

    it 'backup name being set when base url is domain' do
        @wayback_machine_downloader.base_url = 'thomaston4thofjuly.com'
        
        expect(@wayback_machine_downloader.backup_name).to eq('thomaston4thofjuly.com')
    end

    it 'adding trailing slash to backup path when it was not contains' do
        @wayback_machine_downloader.directory = '/docs/blog'

        actual_backup_path = @wayback_machine_downloader.backup_path

        expect(actual_backup_path).to eq('/docs/blog/')
        expect(actual_backup_path).not_to eq('/docs/blog')
    end

    it 'keep backup path untouched when it was contains trailing slash' do
        @wayback_machine_downloader.directory = '/docs/blog/'
        
        actual_backup_path = @wayback_machine_downloader.backup_path
        
        expect(actual_backup_path).to eq('/docs/blog/')
        expect(actual_backup_path).not_to eq('/docs/blog')
    end

    it 'cdx file path being set' do       
        @wayback_machine_downloader.directory = '/docs/blog/'
        
        expected = "/docs/blog/.cdx.json"
        expect(@wayback_machine_downloader.cdx_path).to eq(expected)
    end

    it 'db file path being set' do
        @wayback_machine_downloader.directory = '/docs/blog/'

        expected = "/docs/blog/.downloaded.txt"

        expect(@wayback_machine_downloader.db_path).to eq(expected)
    end

    it 'resetting download state files' do
        
        @wayback_machine_downloader.reset = true
        @wayback_machine_downloader.directory = "/docs/blog/"
        

        db_path = "/docs/blog/.downloaded.txt"
        cdx_path = "/docs/blog/.cdx.json"

        expect { @wayback_machine_downloader.handle_reset }.to output("Resetting download state...\nRemoved state files: #{cdx_path}, #{db_path}\n").to_stdout
    end

    it 'filter images from file list' do
        @wayback_machine_downloader.only_filter = "/\.(jpg|png)/i"

        result = @wayback_machine_downloader.get_file_list_curated

        expect(result["pix/Flair4.jpg"][:file_url].to_s).to eq("http://www.thomaston4thofjuly.com:80/pix/Flair4.jpg")
        
        expect(result["assets/img/vendors-1.jpg"][:file_url].to_s).to eq("http://www.thomaston4thofjuly.com/assets/img/vendors-1.jpg")
        
        expect(result["assets/img/android-icon-192x192.png"][:file_url].to_s).to eq("https://www.thomaston4thofjuly.com/assets/img/android-icon-192x192.png")

        expect { 
            @wayback_machine_downloader.get_file_list_by_timestamp
        }.to output(/File url doesn't match only filter, ignoring: .*/).to_stdout
    end

    it 'filter file list with invalid regexp' do
        @wayback_machine_downloader.only_filter = "/unclosed["

        expect(@wayback_machine_downloader.get_file_list_curated).to be_empty
    end

    it 'bypassing filter with Nil pattern' do
        @wayback_machine_downloader.only_filter = nil

        result = @wayback_machine_downloader.get_file_list_curated

        expect(result["sitemap.xml"][:file_url].to_s).to eq("https://thomaston4thofjuly.com/sitemap.xml")
        expect(result["sponsors.cfm"][:file_url].to_s).to eq("http://www.thomaston4thofjuly.com:80/sponsors.cfm")
        expect(result["assets/crafter2018.pdf"][:file_url].to_s).to eq("http://www.thomaston4thofjuly.com/assets/crafter2018.pdf")
    end

    it 'excluding image (gif, png, jp(e)g) files from file list' do
        pattern_exclude = /\.(gif|png|jpg|jpeg)+/i
        pattern_include = /\.(css|html|js|pdf)+/i

        @wayback_machine_downloader.reset = true
        @wayback_machine_downloader.exclude_filter = "/\.(gif|png|jpg|jpeg)+/i"

        result = @wayback_machine_downloader.get_file_list_curated

        expect(result.values.map { |d| d[:file_url] }.any? { |url| url.match?(pattern_exclude) }).not_to be true

        expect(result.values.map { |d| d[:file_url] }.any? { |url| url.match?(pattern_include) }).to be true

    end

    it 'bypass exclude filter with invalid regexp' do
        @wayback_machine_downloader.reset = true
        @wayback_machine_downloader.exclude_filter = "\./unclosed["

        result = @wayback_machine_downloader.get_file_list_curated

        expect(result["sitemap.xml"][:file_url].to_s).to eq("https://thomaston4thofjuly.com/sitemap.xml")
        expect(result["sponsors.cfm"][:file_url].to_s).to eq("http://www.thomaston4thofjuly.com:80/sponsors.cfm")
        expect(result["assets/crafter2018.pdf"][:file_url].to_s).to eq("http://www.thomaston4thofjuly.com/assets/crafter2018.pdf")
    end

    it 'get all snapshots to consider', :enable_output do
        @wayback_machine_downloader.reset = false
        @wayback_machine_downloader.directory = "/docs/blog/"
        

        db_path = "/docs/blog/.downloaded.txt"
        cdx_path = "/docs/blog/.cdx.json"

        result = @wayback_machine_downloader.get_file_list_curated

        puts "FILE LIST:\n#{@wayback_machine_downloader.get_all_snapshots_to_consider}\n"

        expect { 
            @wayback_machine_downloader.get_all_snapshots_to_consider
        }.to output(/Loading snapshot list from #{cdx_path}\nLoaded \d+ snapshots from cache./).to_stdout
    end

    it 'handles JSON ParserError and deletes the cache file', :enable_output do
        @wayback_machine_downloader.reset = false
        @wayback_machine_downloader.directory = "/build/websites/docs/blog/"

        # Setup: Writes invalid JSON to the file
        cdx_path = "/build/websites/docs/blog/.cdx.json"
        FileUtils.mkdir_p(File.dirname(cdx_path))
        File.write(cdx_path, '{ invalid json')

        expect(File).to exist(cdx_path) 

        expect {
        @wayback_machine_downloader.get_all_snapshots_to_consider
        }.to output(/Error reading snapshot cache file .* Refetching/).to_stdout

    end

    it 'handles unexpected error and deletes the cache file', :enable_output do
        @wayback_machine_downloader.reset = false
        @wayback_machine_downloader.directory = "/build/websites/docs/blog/"

        cdx_path = "/build/websites/docs/blog/.cdx.json"

        allow(File).to receive(:exist?).with(cdx_path).and_return(true)
        allow(@wayback_machine_downloader).to receive(:cdx_path).and_return(cdx_path)
        @wayback_machine_downloader.instance_variable_set(:@reset, false)

        allow(File).to receive(:read).with(cdx_path).and_raise(StandardError.new('disk error'))

        expect {
            @wayback_machine_downloader.get_all_snapshots_to_consider
        }.to output(/Error loading snapshot cache .* Refetching/).to_stdout

        allow(FileUtils).to receive(:rm_f)

    end

    it 'rescues when File.write raises an error' do

        # Stub: File.write dobjon hibát
        allow(File).to receive(:write).and_raise(StandardError.new("disk full"))

        # A mkdir_p még lefuthat rendesen
        allow(FileUtils).to receive(:mkdir_p)

        # Elvárjuk, hogy a hiba kiírásra kerül
        expect {
            @wayback_machine_downloader.get_all_snapshots_to_consider
        }.to output(/Error saving snapshot cache to .*/).to_stdout
    end

    it 'skip file because file id malformed' do
        fake_snapshots = [
            ["20050129045746", "http://www.thomaston4thofjuly.com:80/"],
            ["20220616045815", "http://www.thomaston4thofjuly.com/assets/fonts/fa-solid-900.woff2"], 
            ["20220616045810", "http://www.thomaston4thofjuly.com/assets/fonts/fontawesome-all.min.css"],
            ["20190219011030", "http://www.thomaston4thofjuly.com/assets/2018_vendor_application..pdf"],
            ["20220616045813", "http://www.thomaston4thofjuly.com/assets/img/house.jpg"]
        ]

        nil_file_url = [
            ["20050129045746", ""],
        ]

        allow(@wayback_machine_downloader).to receive(:get_all_snapshots_to_consider).and_return(nil_file_url)

        expect {
            @wayback_machine_downloader.get_file_list_all_timestamps
        }.to output(/Malformed file url, ignoring: .*/).to_stdout
    end

    it 'filter images from file list in all timestamp' do
        @wayback_machine_downloader.only_filter = "/\.(jpg|png)/i"
        @wayback_machine_downloader.reset = true
        @wayback_machine_downloader.all_timestamps = true

        result = @wayback_machine_downloader.get_file_list_by_timestamp

        expect(result.find { |item| item[:file_url].to_s.include?("pix/Flair4.jpg") }[:file_url].to_s).to eq("http://www.thomaston4thofjuly.com:80/pix/Flair4.jpg")
        # expect(result["pix/Flair4.jpg"][:file_url].to_s).to eq("http://www.thomaston4thofjuly.com:80/pix/Flair4.jpg")
        
        # expect(result["assets/img/vendors-1.jpg"][:file_url].to_s).to eq("http://www.thomaston4thofjuly.com/assets/img/vendors-1.jpg")
        
        # expect(result["assets/img/android-icon-192x192.png"][:file_url].to_s).to eq("https://www.thomaston4thofjuly.com/assets/img/android-icon-192x192.png")

        expect { 
            result
        }.to output(/File url doesn't match only filter, ignoring: .*\n/).to_stdout
    end

    after do
        FileUtils.rm_rf(@wayback_machine_downloader.backup_path)
    end
end