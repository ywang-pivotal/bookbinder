require 'git'

module Bookbinder
  class GitAccessor
    def last_modified_date(path_to_local_repo, filename)
      # if has_git_object?(path_to_local_repo)
        git_base_object = Git.open(path_to_local_repo)
        # irrelevant_path_component = directory+'/'
         # = filename.gsub(irrelevant_path_component, '')
        log = git_base_object.log(1)
        obj = log.object(filename)
        p obj
        p obj.first
        date = obj.first.date
        p date
        date
      # end

    end

    private

    def has_git_object?(path_to_repo)
      !!Git.open(path_to_repo)
    end

  end
end