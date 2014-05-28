//
//  HoNManager.h
//  Thermal
//
//  Created by Robert Dunlevie on 4/22/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 *
 */
@interface HoNManager : NSObject


+ (id)sharedHoNManager;

/**
 * Starts location services to be recorded when votes are cast
 */
- (void)startLocationServices;

/**
 * Request information about all companies to be displayed in the VoteCountTVC page.
 * Loads companies in sorted manner based on net plus/minus of up_votes - down_votes
 * Stores result in NSUserDefaults
 */
- (void)loadAllCompanyCards;

/**
 * Requests information about the next set of company cards, as determined by the current page number.
 * Result stored in NSUserDefaults, throws a notification in the case of an error.
 * In the case that the next deck is empty, as flagged by the rails server, the page count is reset and the first deck is loaded again.
 */
- (void)loadDeck;

/**
 * Loads votes information for company provided with param from rails server.
 * Resulting information stored in NSUserDefaults
 
 * @param company the company whose information will be loaded
 */
- (void)loadVoteTypesForCompany:(NSString *) company;

/**
 *  Performs POST Request to rails server, casting a vote of type vote_type for a company passed in.
 *
 *  @param vote_type the type of vote cast
 *  @param company   the company the vote was cast on
 */
- (void)castVote:(NSString *)vote_type forCompany:(NSString *)company;
/**
 *  Performs POST Request to rails server, casting a comparison between winningCompany and losingCompany.
 *  Passes simple bool saying whether the comparison was skipped by the user
 *
 *  @param winningCompany the name of the company that won the comparison
 *  @param losingCompany  the name of the company that lost the comparison
 *  @param wasSkip        bool determining whether the comparison was simply a skip
 */
- (void)castComparisonForCompany:(NSString *) winningCompany overCompany:(NSString *) losingCompany wasSkip:(BOOL)wasSkip;

/**
 *  Loads a deck of all company cards and stores the deck in NSUserDefaults
 *  Deck to be used in the ComparisonViewVC
 */
- (void)loadComparisonsDeck;

/**
 *  Pushes the company card for companyName onto the top of the deck of current company cards being used by the HoNManager
 *
 *
 *  @param companyName the name of the company to be added to the votes deck
 */
- (void)addCompanyToDeck:(NSString *)companyName;

/**
 *  Pops the top company card from the company deck stored inside the HoNManager
 */
- (void)removeTopCompanyFromDeck;

/**
 * Simple method that checks whether the current deck of company cards on the vote page is empty
 *  @return BOOl saying whether the deck is empty
 */
- (BOOL)deckEmpty;

/**
 * Loads the next set of five company cards to the currently displayed checked as determined by our rails server
 */
- (void)loadNextDeck;

/**
 * Increments page count variable that is used to tell rails server which page of company cards to load next
 */
- (void)incrementPageCount;

/**
 * Resets page count back to 0 after the final page of company cards is loaded.
 */
- (void)resetPageCount;
@end
