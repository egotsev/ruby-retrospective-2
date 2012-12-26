class Song
  attr_accessor :name, :artist, :album

  def initialize(name, artist, album)
    @name, @artist, @album = name, artist, album
  end
end

class Collection
  include Enumerable

  attr_reader :songs

  def initialize(songs)
    @songs = songs
  end

  def each
    @songs.each { |song| yield song }
  end

  def Collection.parse(text)
    songs = text.split(/\n+/).each_slice(3).map do |slice|
      Song.new(slice[0], slice[1], slice[2])
    end
    new songs
  end

  def artists
    map(&:artist).uniq
  end

  def albums
    map(&:album).uniq
  end

  def names
    map(&:name).uniq
  end

  def filter(criteria)
    Collection.new select { |song| criteria.matches? song }
  end

  def adjoin(collection)
    Collection.new @songs | collection.songs
  end

  def |(collection)
    adjoin collection
  end
end

class Criteria
  def initialize(&block)
    @filter_proc = block
  end

  def self.name(name)
    new { |song| song.name == name}
  end

  def self.artist(artist)
    new { |song| song.artist == artist}
  end

  def self.album(album)
    new { |song| song.album == album}
  end

  def matches?(song)
    @filter_proc.(song)
  end

  def &(other)
    Criteria.new { |song| matches?(song) and other.matches?(song)}
  end

  def |(other)
    Criteria.new { |song| matches?(song) or other.matches?(song)}
  end

  def !
    Criteria.new { |song| !matches?(song) }
  end
end
