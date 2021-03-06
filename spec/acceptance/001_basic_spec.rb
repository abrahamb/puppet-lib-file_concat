require 'spec_helper_acceptance'

shell("mkdir -p #{default['distmoduledir']}/another/templates")
shell("mkdir -p #{default['distmoduledir']}/another/files")
scp_to(default, 'spec/fixtures/content.erb', "#{default['distmoduledir']}/another/templates/content.erb")
scp_to(default, 'spec/fixtures/file1', "#{default['distmoduledir']}/another/files/file1")
scp_to(default, 'spec/fixtures/file2', "#{default['distmoduledir']}/another/files/file2")

describe "File Concat" do

  describe "file fragment content" do

    describe "single fragment" do
      it 'should run successfully' do
        pp = "file_fragment { 'fragment_1': content => 'mycontent', tag => 'mytag' }
              file_concat { 'myfile': tag => 'mytag', path => '/tmp/concat' }
             "
        apply_manifest(pp, :catch_failures => true)
        expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

      end
   
      describe file('/tmp/concat') do
        it { should be_file }
        its(:content) { should match /mycontent/ }
      end
    end

    describe "multiple fragments" do
      it 'should run successfully' do
        pp = "file_fragment { 'fragment_1': content => 'mycontent', tag => 'mytag', order => 10 }
              file_fragment { 'fragment_2': content => 'mycontent2', tag => 'mytag', order => 11 }
              file_concat { 'myfile': tag => 'mytag', path => '/tmp/concat' }
             "
        apply_manifest(pp, :catch_failures => true)
        expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

      end
   
      describe file('/tmp/concat') do
        it { should be_file }
        its(:content) { should match /mycontentmycontent2/ }
      end

    end
   
  end

  describe "file fragment template" do

    describe "single fragment" do
      it 'should run successfully' do
        pp = "
              $var = 'something'
              file_fragment { 'fragment_1': content => template('another/content.erb'), tag => 'mytag' }
              file_concat { 'myfile': tag => 'mytag', path => '/tmp/concat' }
             "
        apply_manifest(pp, :catch_failures => true)
        expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

      end
   
      describe file('/tmp/concat') do
        it { should be_file }
        its(:content) { should match /this is my content with something/ }
      end
    end

    describe "multiple fragments" do
      it 'should run successfully' do
        pp = "
              $var = 'something2'
              file_fragment { 'fragment_1': content => template('another/content.erb'), tag => 'mytag' }
              file_fragment { 'fragment_2': content => template('another/content.erb'), tag => 'mytag' }
              file_concat { 'myfile': tag => 'mytag', path => '/tmp/concat' }
             "
        apply_manifest(pp, :catch_failures => true)
        expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

      end
   
      describe file('/tmp/concat') do
        it { should be_file }
        its(:content) { should match /this is my content with something2\nthis is my content with something2/ }
      end

    end
   
  end

  describe "file fragment source" do

    describe "single fragment" do
      it 'should run successfully' do
        pp = "
              file_fragment { 'fragment_1': source => 'puppet:///modules/another/file1', tag => 'mytag' }
              file_concat { 'myfile': tag => 'mytag', path => '/tmp/concat' }
             "
        apply_manifest(pp, :catch_failures => true)
        expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

      end
   
      describe file('/tmp/concat') do
        it { should be_file }
        its(:content) { should match /contentfile1/ }
      end
    end

    describe "multiple fragments" do
      it 'should run successfully' do
        pp = "
              file_fragment { 'fragment_1': source => 'puppet:///modules/another/file1', tag => 'mytag' }
              file_fragment { 'fragment_2': source => 'puppet:///modules/another/file2', tag => 'mytag' }
              file_concat { 'myfile': tag => 'mytag', path => '/tmp/concat' }
             "
        apply_manifest(pp, :catch_failures => true)
        expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

      end
   
      describe file('/tmp/concat') do
        it { should be_file }
        its(:content) { should match /contentfile1\ncontentfile2/ }
      end

    end

    describe "non existing fragment" do
      it 'should run successfully' do
        pp = "
              file_fragment { 'fragment_1': source => 'puppet:///modules/another/file3', tag => 'mytag' }
              file_concat { 'myfile': tag => 'mytag', path => '/tmp/concat' }
             "
        apply_manifest(pp, :catch_failures => true)
        expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

      end

      describe file('/tmp/concat') do
        it { should be_file }
        its(:content) { should match // }
      end
    end
   
  end

end
