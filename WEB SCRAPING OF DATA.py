import requests 
from bs4 import BeautifulSoup
import csv 
date=input("please enter a date like mm/dd/yyyy ")
page=requests.get(f"https://www.yallakora.com/match-center/%d9%85%d8%b1%d9%83%d8%b2-%d8%a7%d9%84%d9%85%d8%a8%d8%a7%d8%b1%d9%8a%d8%a7%d8%aa?date={date}")

def main(page):
 src=page.content
    #print(src)
 soup=BeautifulSoup(src,"lxml")
    #print(soup)
 matches_details=[]
 championships=soup.find_all("div",{'class':'matchCard'})
 #print(championships)
 def get_match_info (championships):
       championship_title=championships.contents[1].find('h2').text.strip()
       #print(championship_title)
       all_matches=championships.contents[3].find_all('div',{'class':'item finish liItem'})
       #all_matches=championships.contents[3].contents[3].find('div',{'class':'teamA'}).text.strip()
       #all_matches=championships.contents[3].contents[3]
       number_of_matches=len(all_matches) 
       #print(championship_title)
       #print(all_matches[0].find('div',{'class':'teamB'}).text.strip())
       #print(number_of_matches)
        #print(number_of_matches)
       for i in range(number_of_matches):
        #get teams names
         team_A=all_matches[i].find('div',{'class':'teamA'}).text.strip()
         team_B=all_matches[i].find('div',{'class':'teamB'}).text.strip()
        #get score 
         match_result=all_matches[i].find('div',{'class':'MResult'}).find_all('span',{'class':'score' })
         result1=f"{match_result[0].text.strip()}"
         result2=f"{match_result[1].text.strip()}"
         score=result1+"-"+result2
        #get match time
         match_time=all_matches[i].find('div',{'class':'MResult'}).find('span',{'class':'time'}).text.strip()
         print(team_A+" "+ team_B+" "+ score+" "+match_time)
        # add match info to matches details
         matches_details.append({"championship":championship_title,"the first team":team_A
          ,"the second team":team_B,"the score" :score,"match time":match_time})
 for i in range(len(championships)):
  get_match_info(championships[i])

  keys=matches_details[0].keys()
  with open('matches_scores.csv','w') as output_files:
       dict_writer=csv.DictWriter(output_files,keys)
       dict_writer.writeheader()
       dict_writer.writerows(matches_details)
       print("file created")  
main(page)

