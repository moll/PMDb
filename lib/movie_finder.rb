class MovieFinder
  def initialize(options)
    @options = options
  end

  def movies
    parse movie_files
  end

  private

  def movie_files
    @options["directories"].reduce({}) do |result_memo, dir|
      dirs = Pathname.new(dir).children.select(&:directory?)
      movie_files_in_dirs = dirs.reduce([]) do |memo, d|
        file = d.children.detect do |f|
          f.file? && (f.nfo? || f.video?)
        end
        memo << file
      end.compact

      result_memo[dir] ||= []
      result_memo[dir] += movie_files_in_dirs
      result_memo
    end
  end

  def parse(dirs)
    dirs.each_pair do |dir, files|
     movie_objects = Parallel.map(files, :in_threads => 0) do |file|
       {imdb: IMDb.new(file), path: file.dirname.to_s, mtime: file.mtime}
     end
     dirs[dir] = movie_objects
    end
    dirs
  end

end