class CompaniesController < ApplicationController
  protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/json' }


  before_action :set_company, only: [:show, :edit, :update, :destroy]

  # GET /companies
  # GET /companies.json
  def index
    @companies = Company.paginate(:order => "name ASC", :page => params[:page], :per_page => 5)
    arr = Array.new
    @companies.each{ |company|
      arr.push({name: company.name})
    }
      
    respond_to do |format|
      format.html {render json: @companies }#temporary
      format.json { render json: arr }
    end
  end

  #GET /company/getall
  #GET /company/getall.json
  def getall
    companies = Company.all;
    arr = Array.new
    companies.each{ |company|
      netTotal = company.votes.where(vote_type: "up_vote").count - company.votes.where(vote_type: "down_vote").count

      arr.push({name: company.name,  netTotal: netTotal, votes: company.votes})
    }
    arr.sort_by {|elem| -elem[:netTotal] }

    respond_to do |format|
      format.html {render json: @companies }#temporary
      format.json { render json: arr }
    end
  end
  # GET /companies/1
  # GET /companies/1.json
  def show

  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies
  # POST /companies.json
  def create
    @company = Company.new(company_params)

    respond_to do |format|
      if @company.save
        format.html { redirect_to @company, notice: 'Company was successfully created.' }
        format.json { render action: 'show', status: :created, location: @company }
      else
        format.html { render action: 'new' }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to @company, notice: 'Company was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /company/lookup
  #GET /company/lookup.json
  # Looks up a company pertaining to a specific name
  def lookup
    @company = Company.find_by(name: params[:name])
    map = { company: @company, votes: @company.votes }
    
    respond_to do |format|
      format.html { redirect_to @company}
      format.json { render json: map }
    end
  end
  
  # PATCH/PUT /vote
  # Records a single vote for a single company
  # Need to pass in params of name, vote_type and vote_location
  def vote
    @company = Company.find_by(name: params[:name])

    vote = Vote.new
    vote.company = params[:name]
    vote.vote_type = params[:vote_type] 
    vote.vote_location = params[:vote_location]
    vote.device_id = params[:device_id]

    if !@company.nil?
      @company.votes << vote
    end

    respond_to do |format|
      if @company.save
        format.html { redirect_to @company, notice: 'Company was successfully updated.' }
        format.json { render json: @company }
      else
        format.html { render action: 'edit' }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  #GET /vote/lookup
  #GET /vote/lookup.json
  def voteLookup
    @company = Company.find_by(name: params[:name])
    vote_type = params[:vote_type]
    respond_to do |format|
      format.html { redirect_to @company}
      if vote_type.nil?
        format.json { render json: @company.votes }
      else
        format.json {render json: @company.votes.where(vote_type: vote_type)}
      end
    end

  end

  #GET /vote/count
  #GET /vote/count.json
  #Given company name, returns count of each vote type
  def voteCount
    @company = Company.find_by(name: params[:name])
    trendingArray = recentTrendingArray(@company)
    votes = Hash.new
    votes["up_votes"] = @company.votes.where(vote_type: "up_vote").count
    votes["down_votes"] = @company.votes.where(vote_type: "down_vote").count
    votes["unknown_votes"] = @company.votes.where(vote_type: "unknown_vote").count
    votes["trendingArray"] = trendingArray

    respond_to do |format|
      format.html { redirect_to @company}
      format.json { render json: votes }
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company.destroy
    respond_to do |format|
      format.html { redirect_to companies_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
    end

    #gets an array of a companies net vote count over the last 10 days
    def recentTrendingArray(company)
      i = 0
      votes = company.votes
      trendingArray = Array.new
      while i < 10
        net = votes.where("vote_type = 'up_vote' AND created_at <=  ?", i.days.ago).count
        net -= votes.where("vote_type = 'down_vote' AND created_at <=  ?", i.days.ago).count
        trendingArray.push(net)
        i += 1
      end
      trendingArray
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit(:name, :vote_type, :vote_location, :page, :device_id)
    end
end
