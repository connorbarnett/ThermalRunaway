#Main brains controller of application, contains all logic for CRUD operations on all companies, votes and comparisons
class CompaniesController < ApplicationController
  protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/json' }

  #made to allow POST requests to cast comparison votes
  skip_before_filter :verify_authenticity_token, :only => [:compare]

  before_action :set_company, only: [:show, :edit, :update, :destroy]

  # GET /companies
  # GET /companies.json
  #Given a page number, returns the nth page of companies, with each page being 5 companies long
  # To avoid transferring unnecessary data, a new array is returned that simply contains the names
  # of the 5 companies being returned
  #Requires param of page number to return
  # Returns a json array of the 5 companies on the nth page
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
  #Returns an array of hashes, with each hash containing a company's name and its net total of upvotes - downvotes
  #Adds one hash into the array for each company in the company model, hash to be used in VoteCountTVC in iPhone app
  #Requires no params
  #Returns the json format of the array of hashes described above
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
  #given a device_id, returns an array of all companies that the device_id has voted on.  
  #this array is to be used in the comparisonsViewVC on the iPhone application 
  #for now and quick development just returning all companies for comparisons.  
  #need to pass device_id.  
  #returns json array of the companies that were passed.  
  def getcomparisons
    device_id = params[:device_id]
    companies = Company.all
    arr = Array.new
    companies.each{ |company|
      votes = company.votes
      # if votes.where(device_id: device_id).count != 0
        arr.push(company)#for now just adding everything
      # end
    }

    respond_to do |format|
      format.html {render json: companies }#temporary
      format.json { render json: arr }
    end
  end

  #GET /company/compareinfo
  #GET /company/compareinfo.json
  #given a company name, returns a hash containing information on both 
  #comparisons the company has won and lost.  
  #need to pass company name as only param.  
  #hash of company's comparison information returned.
  def compareInfo
    company = Company.find_by(name: params[:name])
    hash = Hash.new
    winningCompares = Comparison.where(winning_company_id: company.id, was_skip: false)
    losingCompares = Comparison.where(losing_company_id: company.id, was_skip: false)

    hash["winningCompares"] = winningCompares
    hash["losingCompares"] = losingCompares
    respond_to do |format|
      format.html { redirect_to @company, notice: 'Company was successfully created.' }
      format.json { render json: hash}
    end
  end

  #GET /company/comparePercentage
  #GET /company/comparePercentage.json
  #Given two company names, determines which company has won more comparisons.
  #Returns hash containing winning company's name and percent of votes they won.
  #Need to pass two params: first_company_name and second_company_name.
  #returns hash described above.
  def comparePercentage
    firstCompany = Company.find_by(name: params[:first_company_name])
    secondCompany = Company.find_by(name: params[:second_company_name])
    firstWins = Comparison.where(winning_company_id: firstCompany.id, losing_company_id: secondCompany.id, was_skip: false).count
    secondWins = Comparison.where(winning_company_id: secondCompany.id, losing_company_id: firstCompany.id, was_skip: false).count
    result = Hash.new

    if firstWins == 0 and secondWins == 0
      result["winning_company_name"] = firstCompany.name
      result["losing_company_name"] = secondCompany.name
      result["winPercentage"] = -1
    end
    if firstWins == secondWins and firstWins != 0
      result["winning_company_name"] = firstCompany.name
      result["losing_company_name"] = secondCompany.name
      result["winPercentage"] = -2
    end
    if firstWins > secondWins
      result["winning_company_name"] = firstCompany.name
      result["losing_company_name"] = secondCompany.name
      result["winPercentage"] = (1.0*firstWins)/(firstWins+secondWins)
    end
    if firstWins < secondWins
      result["winning_company_name"] = secondCompany.name
      result["losing_company_name"] = firstCompany.name
      result["winPercentage"] = (1.0*secondWins)/(firstWins+secondWins)
    end

    respond_to do |format|
      format.html { redirect_to firstCompany, notice: 'Company was successfully created.' }
      format.json { render json: result}
    end      

  end

  # GET /companies/1
  # GET /companies/1.json
  # autogenerated rails method
  def show

  end

  # GET /companies/new
  # autogenerated rails method
 def new
    @company = Company.new
  end

  # GET /companies/1/edit
  # autogenerated rails method
  def edit
  end

  # POST /companies
  # POST /companies.json
  # autogenerated rails method
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
  # autogenerated rails method
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
  
  #POST /compare
  #POST /compare.json
  #Responds to HTTP POST Request to cast a comparison between two companies
  #Has the comparison belong to both the winning company and the losing company
  #If the comparison was a skipped comparison, the winning or losing company pointers are
  #determined arbitrarily.
  #Needs to pass in name of winningCompany, losingCompany, vote_location, device_id and boolean saying if comparison was a skip
  #Returns winningCompany's json object on success and winningCompany's error json object on failure
  def compare
    winningCompany = Company.find_by(name: params[:winningCompany])
    losingCompany = Company.find_by(name: params[:losingCompany])
    comparison = Comparison.new
    comparison.winning_company = winningCompany
    comparison.losing_company = losingCompany
    comparison.winning_company_name = winningCompany.name
    comparison.losing_company_name = losingCompany.name
    comparison.device_id = params[:device_id]
    comparison.vote_location = params[:vote_location]
    comparison.was_skip = params[:was_skip] == "1" ? true : false

    respond_to do |format|
      if comparison.save
        format.html { redirect_to winningCompany, notice: 'Comparison succesfully recorded.' }
        format.json { render json: winningCompany }
      else
        format.html { render action: 'edit' }
        format.json { render json: winningCompany.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /vote
  # POST /vote.json
  # Records a single vote for a single company
  # Need to pass in params of name, vote_type and vote_location and device_id
  # Renders company's json object on success and error report on failure
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
  #Info includes both trendingArray and rankingArray displayed by iPhone app's companyProfileVC
  #Also includes total count of upvotes, downvotes and unknownvotes
  #Needs to pass in parms of name, being the company's name
  #Renders json object including information described above
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

    #gets an array of a companies ranking among others within a single day over the last 10 days
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
