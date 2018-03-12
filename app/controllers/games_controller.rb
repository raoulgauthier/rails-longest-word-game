require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    grid_size = 10
    @grid = generate_grid(grid_size)
  end

  def score
    @start_time = Time.now
    @attempt = params[:answer]
    @end_time = Time.now
    @time_taken = @end_time - @start_time
    @score = score_and_message(@attempt, @grid)
  end

private
  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a.sample }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  # def run_game(attempt, grid, start_time, end_time)
  #   @result = { time: end_time - start_time }
  #   start_time = Time.now
  #   score_and_message = score_and_message(@attempt, @grid, @result[:time])
  #   @result[:score] = score_and_message.first
  #   @result[:message] = score_and_message.last
  #   end_time = Time.now
  #   @result
  # end

  def score_and_message(attempt, grid)
    if include_content?(@attempt.upcase)
      if english_word?(@attempt)
        score = compute_score(@attempt, @time_taken)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def english_word?(attempt)
    response = open("https://wagon-dictionary.herokuapp.com/#{attempt}")
    json = JSON.parse(response.read)
    return json['found']
  end

end

