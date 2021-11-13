require 'json'
require 'open-uri'

class GamesController < ApplicationController
  def generate_grid(grid_size)
    Array.new(grid_size) do |_element|
      (:A..:Z).to_a.sample
    end
  end

  def new
    grid_size = 10
    @grid = generate_grid(grid_size)
  end

  def check_word(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    JSON.parse(URI.open(url).read)
  end

  def check_grid?(word, grid)
    new_grid = grid.join.downcase.chars
    word.downcase.chars.each do |char|
      return false unless new_grid.include? char

      new_grid.delete_at(new_grid.find_index(char))
    end
    true
  end

  def score
    end_time = Time.now.to_i
    word = params[:word]
    start_time = params[:start_time].to_i
    @grid = params[:grid]
    grid = @grid.split(' ')
    if session[:score].nil?
      session[:score] = 0
    end
    if check_word(word)['found'] && check_grid?(word, grid)
      @test = { score: (word.length * 10) + (100 - (end_time - start_time)) + session[:score], message: 'ok',
                time: (end_time - start_time), word: word }
    elsif check_word(word)['found'] && !check_grid?(word, grid)
      @test = { score: 0 + session[:score], message: 'not_grid', time: (end_time - start_time), word: word }
    elsif !check_word(word)['found'] && check_grid?(word, grid)
      @test = { score: 0 + session[:score], message: 'not_valid', time: (end_time - start_time), word: word }
    else
      @test = { score: 0 + session[:score], message: 'not_grid_valid', time: (end_time - start_time), word: word }
    end
  end
end
