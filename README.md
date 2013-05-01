# hackatus
Hackathon status shown in Panic Status Board!

## The origin
We are holding a hackathon where there are bunch of projects. We want to build something that helps the participants to find how well they are doing and how the other teams are doing. Then [@zhf](https://zhf) found the app called [Status Board](http://panic.com/statusboard/) developed by [panic.com](http://panic.com). And we decided to build a service that conforms the protocol, so our projects' status can be tracked && displayed in that app.

## Implementation
The whole project is nothing more than a web service entry. By accessing the url, you can get the latestest data on those projects. 

The project is powered by [sinatra](http://www.sinatrarb.com/), a lightweight web framework that does the weight-lift for you, so you can focus on the web logic. 

## Web service API
### Repo commits
Here's a working version of this api [here](http://hackatus.herokuapp.com/summary.json). Basically, this repo summarizes the commit info of the repo.

### Repo hotness
The working version can be found [here](http://hackatus.herokuapp.com/table.html), this partial html is used to be displayed by Status Board. 
