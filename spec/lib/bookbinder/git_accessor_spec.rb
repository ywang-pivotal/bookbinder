require_relative '../../../lib/bookbinder/git_accessor'

module Bookbinder
  describe GitAccessor do
    it 'fetching the last modified date of a file' do
      vcs_accessor = GitAccessor.new
      path_to_local_repo = File.expand_path('../../../fixtures/repositories/my-git-object-repo', __FILE__)
      filename = 'dont_modify_me.md'

      expect(vcs_accessor.last_modified_date(path_to_local_repo, filename)).to eq '17:33 1/19/2015'
    end
  end
end