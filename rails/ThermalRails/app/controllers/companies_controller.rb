class CompaniesController < ApplicationController
  protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/json' }
  skip_before_filter :verify_authenticity_token, :only => [:compare]

  before_action :set_company, only: [:show, :edit, :update, :destroy]

  # GET /companies
  # GET /companies.json
  def index
    @companies = Company.paginate(:page => params[:page], :per_page => 5)
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

      arr.push({name: company.name,  netTotal: netTotal})
    }
    arr.sort_by! {|elem| -elem[:netTotal] }

    respond_to do |format|
      format.html {render json: @companies }#temporary
      format.json { render json: arr }
    end
  end

  #GET /company/getcomparisons
  #GET /company/getcomparisons.json
  def getcomparisons
    device_id = params[:device_id]
    companies = Company.all
    arr = Array.new
    companies.each{ |company|
      votes = company.votes
      if votes.where(device_id: device_id).count != 0
        arr.push(company)#for now just adding everything
      end
    }

    respond_to do |format|
      format.html {render json: companies }#temporary
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
  
  def compare
    winningCompany = Company.find_by(name: params[:winningCompany])
    losingCompany = Company.find_by(name: params[:losingCompany])
    comparison = Comparison.new
    comparison.winning_company = winningCompany
    comparison.losing_company = losingCompany
    comparison.device_id = params[:device_id]
    comparison.vote_location = params[:vote_location]
    comparison.was_skip = params[:was_skip] == "1" ? true : false

    respond_to do |format|
      if comparison.save
        format.html { redirect_to winningCompany, notice: 'Comparison succesfully recorded.' }
        format.json { render json: winningCompany }
      else
        format.html { render action: 'edit' }
        format.json { render json: winningCompany, status: :unprocessable_entity }
      end
    end
  end

  # POST /vote
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


  #GET /vote/info
  #GET /vote/info.json
  #Given company name, returns info about companies votes over time
  def voteInfo
    @company = Company.find_by(name: params[:name])
    trendingArray = recentTrendingArray(@company)
    rankingArray = recentRankingArray(@company)
    votes = Hash.new
    votes["up_votes"] = @company.votes.where(vote_type: "up_vote").count
    votes["down_votes"] = @company.votes.where(vote_type: "down_vote").count
    votes["unknown_votes"] = @company.votes.where(vote_type: "unknown_vote").count
    votes["trendingArray"] = trendingArray
    votes["rankingArray"] = rankingArray

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

    #gets an array of a companies ranking among others over the last 10 days
    def recentRankingArray(company)
      i = 6
      if company.nil?
        return Array.new
      else
        companies = Company.all;
        rankingArray = Array.new
        while i >= 0
          arr = Array.new
          companies.each{ |company|
            netTotal = company.votes.where("vote_type = 'up_vote' AND created_at <= ? AND created_at >= ?", i.days.ago, (i+1).days.ago).count
            netTotal -= company.votes.where("vote_type = 'down_vote' AND created_at <=  ? AND created_at >= ?", i.days.ago, (i+1).days.ago).count

            arr.push({name: company.name,  netTotal: netTotal})
          }
         
          arr.sort_by! {|elem| -elem[:netTotal] }
           
          index = arr.index {|elem| elem[:name] == company.name }
          if index.nil?
            rankingArray.push(-1)
          else
            rankingArray.push(index + 1)#so the first company is ranked first, not 0
          end

          i -= 1
        end
      end
      rankingArray
    end

    #gets an array of a companies net vote count over the last 10 days
    def recentTrendingArray(company)
      i = 6
      votes = company.votes
      trendingArray = Array.new
      while i >= 0 

        net = votes.where("vote_type = 'up_vote' AND created_at <=  ?", i.days.ago).count
        net -= votes.where("vote_type = 'down_vote' AND created_at <=  ?", i.days.ago).count
        trendingArray.push(net)
        i -= 1
      end
      trendingArray
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit(:name, :vote_type, :vote_location, :page, :device_id)
    end
end
