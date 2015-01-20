require_relative '../../../lib/bookbinder/repositories/section_repository'
require_relative '../../../lib/bookbinder/section'
require_relative '../../helpers/tmp_dirs'
require_relative '../../helpers/nil_logger'
require_relative '../../helpers/spec_git_accessor'

module Bookbinder
  describe Section do
    include_context 'tmp_dirs'

    let(:logger) { NilLogger.new }
    let(:repository) {
      Repositories::SectionRepository.new(
        logger,
        store: {},
        build: ->(*args) { Section.new(*args) },
        git_accessor: SpecGitAccessor
      )
    }

    describe '#subnav_template' do
      let(:vcs_accessor) { double('vcs_accessor', open: nil) }
      let(:repo) { Section.new(double(:repo), subnav_template_name, 'path/to/repository', vcs_accessor) }

      context 'when the incoming template does not look like a partial file' do
        let(:subnav_template_name) { 'my_template' }

        it 'is unchanged' do
          expect(repo.subnav_template).to eq('my_template')
        end
      end

      context 'when the incoming template looks like a partial file' do
        let(:subnav_template_name) { '_my_tem.erbplate.erb' }

        it 'is trimmed' do
          expect(repo.subnav_template).to eq('my_tem.erbplate')
        end
      end

      context 'when the incoming template is not defined' do
        let(:subnav_template_name) { nil }

        it 'is nil' do
          expect(repo.subnav_template).to be_nil
        end
      end
    end

    describe '#get_modification_date_for' do
      let(:local_repo_dir) { '/some/dir' }
      let(:repo_name) { 'farm/my_cow_repo' }
      let(:vcs_accessor) { double('vcs_accessor') }
      let(:repo) { GitHubRepository.new(full_name: repo_name, local_repo_dir: local_repo_dir) }
      subject(:section) { Section.new(repo, 'my_template', 'path/to/farm', vcs_accessor) }
      let(:file) { 'some-file' }
      let(:git_base_object) { double Git::Base }
      let(:time) { Time.new(2011, 1, 28) }

      it 'delegates to the vcs_accessor' do
        expect(vcs_accessor).to receive(:last_modified_date).with(local_repo_dir, file)
        section.get_modification_date_for(file: file, full_path: local_repo_dir)
      end

      context 'when publishing from local' do
        before do
          allow(repo).to receive(:has_git_object?).and_return(false)
        end

        it 'creates the git object locally' do
          allow(repo).to receive(:get_modification_date_for).with(file: file, git: git_base_object).and_return(time)
          expect(Git).to receive(:open).with(local_repo_dir+'/my_cow_repo').and_return(git_base_object)
          expect(section.get_modification_date_for(file: file)).to eq time
        end

        it 'raises if the local repo does not exist or is not a git repo' do
          allow(Git).to receive(:open).with(local_repo_dir+'/my_cow_repo').and_raise
          expect { section.get_modification_date_for(file: file) }.
              to raise_error('Invalid git repository! Cannot get modification date for section: /some/dir/my_cow_repo.')
        end

        it 'passes the git base object to the repository' do
          allow(Git).to receive(:open).with(local_repo_dir+'/my_cow_repo').and_return(git_base_object)
          expect(repo).to receive(:get_modification_date_for).with(file: file, git: git_base_object)
          section.get_modification_date_for(file: file)
        end
      end

      context 'when publishing from remote' do
        let(:time) { Time.new(2011, 1, 28) }

        before do
          allow(repo).to receive(:has_git_object?).and_return(true)
        end

        it 'gets the last modified date of the repository' do
          allow(repo).to receive(:get_modification_date_for).with(file: file, git: nil).and_return(time)
          expect(section.get_modification_date_for(file: file)).to eq time
        end

        it 'passes nil as the git object to the repository' do
          expect(repo).to receive(:get_modification_date_for).with(file: file, git: nil)
          section.get_modification_date_for(file: file)
        end
      end
    end
  end
end
