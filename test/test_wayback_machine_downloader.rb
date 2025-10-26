require 'minitest/autorun'
require 'wayback_machine_downloader'

#
# Target file: lib/wayback_machine_downloader.rb
#
class WaybackMachineDownloaderTest < Minitest::Test

  def setup
    @wayback_machine_downloader = WaybackMachineDownloader.new(
      base_url: 'https://thomaston4thofjuly.com'
    )
    $stdout = StringIO.new
  end

  def shutdown
    FileUtils.rm_rf(@wayback_machine_downloader.backup_path)
  end

  #
  # Target function / method: initialize
  #
  def test_base_url_being_set
    assert_equal 'https://thomaston4thofjuly.com', @wayback_machine_downloader.base_url
    refute_equal 'https://example.com', @wayback_machine_downloader.base_url
  end
  
  # 
  # Target function / method: backup_name
  #
  def test_backup_name_being_set
    assert_equal 'thomaston4thofjuly.com', @wayback_machine_downloader.backup_name
    refute_equal 'https://thomaston4thofjuly.com', @wayback_machine_downloader.backup_name
  end

  #
  # Target function / method: backup_name
  #
  def test_backup_name_being_set_when_base_url_is_domain
    @wayback_machine_downloader.base_url = 'thomaston4thofjuly.com'
    assert_equal 'thomaston4thofjuly.com', @wayback_machine_downloader.backup_name
  end


  #
  # Target function / method: backup_path
  #
  # Tests the app keep trailing slash in the backup (saving) path when it was contains.
  #
  #
  # Passed params:
  # - directory = '/docs/blog/'
  #
  # Expected result:
  # @wayback_machine_downloader.backup_path = '/docs/blog/'
  #
  def test_keep_trailing_slash_in_backup_path
    @wayback_machine_downloader.directory = '/docs/blog/'

    assert_equal '/docs/blog/', @wayback_machine_downloader.backup_path
    refute_equal '/docs/blog', @wayback_machine_downloader.backup_path
  end

end
