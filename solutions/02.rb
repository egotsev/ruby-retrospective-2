class Song
  attr_accessor :name, :artist, :album

  def initialize(name, artist, album)
    @name = name
    @artist = artist
    @album = album
  end
end

class Collection
  attr_accessor :songs

  include Enumerable

  def initialize
    @songs = []
  end

  def each
    @songs.each { |song| yield song }
  end

  def Collection.parse(text)
    new_collection = Collection.new
    text.split(/\n+/).each_slice(3) do |slice|
      new_collection.songs << Song.new(slice[0], slice[1], slice[2])
    end
    new_collection
  end

  def artists
    map { |song| song.artist }.uniq
  end

  def albums
    map { |song| song.album }.uniq
  end

  def names
    map { |song| song.name }.uniq
  end

  def filter(criteria)
    new_collection = Collection.new
    new_collection.songs = select { |song| criteria.match? song }
    new_collection
  end

  def adjoin(collection)
    adjoined = Collection.new
    adjoined.songs = self.songs | collection.songs
    adjoined
  end
end

class Criteria
  def initialize(filter_string)
    @filter_string = filter_string
  end

  def self.name(filter_string)
    NameCriteria.new(filter_string)
  end

  def self.artist(filter_string)
    ArtistCriteria.new(filter_string)
  end

  def self.album(filter_string)
    AlbumCriteria.new(filter_string)
  end

  def &(other)
    DoubleCriteria.new(self, other, :and)
  end

  def |(other)
    DoubleCriteria.new(self, other, :or)
  end

  def !
    ReversedCriteria.new(self)
  end
end

class DoubleCriteria < Criteria
  def initialize(first_criteria, second_criteria, operator)
    @first_criteria = first_criteria
    @second_criteria = second_criteria
    @operator = operator
  end

  def match?(song)
    if @operator == :and
      @first_criteria.match?(song) & @second_criteria.match?(song)
    elsif @operator == :or
      @first_criteria.match?(song) | @second_criteria.match?(song)
    end
  end
end

class ReversedCriteria < Criteria
  def initialize(criteria)
    @criteria = criteria
  end

  def match?(song)
    !@criteria.match? song
  end
end

class NameCriteria < Criteria
  def match?(song)
    song.name.eql? @filter_string
  end
end

class ArtistCriteria < Criteria
  def match?(song)
    song.artist.eql? @filter_string
  end
end

class AlbumCriteria < Criteria
  def match?(song)
    song.album.eql? @filter_string
  end
end
