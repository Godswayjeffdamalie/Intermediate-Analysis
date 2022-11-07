{"metadata":{"kernelspec":{"name":"ir","display_name":"R","language":"R"},"language_info":{"name":"R","codemirror_mode":"r","pygments_lexer":"r","mimetype":"text/x-r-source","file_extension":".r","version":"4.0.5"}},"nbformat_minor":4,"nbformat":4,"cells":[{"source":"<a href=\"https://www.kaggle.com/code/godswayjd/flight-delay?scriptVersionId=110251783\" target=\"_blank\"><img align=\"left\" alt=\"Kaggle\" title=\"Open in Kaggle\" src=\"https://kaggle.com/static/images/open-in-kaggle.svg\"></a>","metadata":{},"cell_type":"markdown","outputs":[],"execution_count":0},{"cell_type":"code","source":"# This R environment comes with many helpful analytics packages installed\n# It is defined by the kaggle/rstats Docker image: https://github.com/kaggle/docker-rstats\n# For example, here's a helpful package to load\n\nlibrary(tidyverse) # metapackage of all tidyverse packages\n\n# Input data files are available in the read-only \"../input/\" directory\n# For example, running this (by clicking run or pressing Shift+Enter) will list all files under the input directory\n\nlist.files(path = \"../input\")\n\n# You can write up to 20GB to the current directory (/kaggle/working/) that gets preserved as output when you create a version using \"Save & Run All\" \n# You can also write temporary files to /kaggle/temp/, but they won't be saved outside of the current session","metadata":{"_uuid":"051d70d956493feee0c6d64651c6a088724dca2a","_execution_state":"idle","execution":{"iopub.status.busy":"2022-11-07T04:27:49.393957Z","iopub.execute_input":"2022-11-07T04:27:49.395853Z","iopub.status.idle":"2022-11-07T04:27:50.787642Z"},"trusted":true},"execution_count":1,"outputs":[{"name":"stderr","text":"── \u001b[1mAttaching packages\u001b[22m ─────────────────────────────────────── tidyverse 1.3.2 ──\n\u001b[32m✔\u001b[39m \u001b[34mggplot2\u001b[39m 3.3.6      \u001b[32m✔\u001b[39m \u001b[34mpurrr  \u001b[39m 0.3.5 \n\u001b[32m✔\u001b[39m \u001b[34mtibble \u001b[39m 3.1.8      \u001b[32m✔\u001b[39m \u001b[34mdplyr  \u001b[39m 1.0.10\n\u001b[32m✔\u001b[39m \u001b[34mtidyr  \u001b[39m 1.2.1      \u001b[32m✔\u001b[39m \u001b[34mstringr\u001b[39m 1.4.1 \n\u001b[32m✔\u001b[39m \u001b[34mreadr  \u001b[39m 2.1.3      \u001b[32m✔\u001b[39m \u001b[34mforcats\u001b[39m 0.5.2 \n── \u001b[1mConflicts\u001b[22m ────────────────────────────────────────── tidyverse_conflicts() ──\n\u001b[31m✖\u001b[39m \u001b[34mdplyr\u001b[39m::\u001b[32mfilter()\u001b[39m masks \u001b[34mstats\u001b[39m::filter()\n\u001b[31m✖\u001b[39m \u001b[34mdplyr\u001b[39m::\u001b[32mlag()\u001b[39m    masks \u001b[34mstats\u001b[39m::lag()\n","output_type":"stream"},{"output_type":"display_data","data":{"text/html":"'flight-delay-prediction'","text/markdown":"'flight-delay-prediction'","text/latex":"'flight-delay-prediction'","text/plain":"[1] \"flight-delay-prediction\""},"metadata":{}}]},{"cell_type":"code","source":"library(car) ## needed to recode variables\n\tset.seed(1)\n\t## read and print the data\n\tdel <- read.csv(\"C:/DataMining/Data/FlightDelays.csv\")\n\tdel[1:3,]\n\t## define hours of departure\n\tdel$sched=factor(floor(del$schedtime/100))\n\ttable(del$sched)\n\ttable(del$carrier)\n\ttable(del$dest)\n\ttable(del$origin)\n\ttable(del$weather)\n\ttable(del$dayweek)\n\ttable(del$daymonth)\n\ttable(del$delay)\n\tdel$delay=recode(del$delay,\"'delayed'=1;else=0\")\n\tdel$delay=as.numeric(levels(del$delay)[del$delay])\n\ttable(del$delay)\n\t## Delay: 1=Monday; 2=Tuesday; 3=Wednesday; 4=Thursday;\n\t## 5=Friday; 6=Saturday; 7=Sunday\n\t## 7=Sunday and 1=Monday coded as 1\n\tdel$dayweek=recode(del$dayweek,\"c(1,7)=1;else=0\")\n\ttable(del$dayweek)\n\t## omit unused variables\n\tdel=del[,c(-1,-3,-5,-6,-7,-11,-12)]\n\tdel[1:3,]\n\tn=length(del$delay)\n\tn\n\tn1=floor(n*(0.6))\n\tn1\n\tn2=n-n1\n\tn2\n\n\ttrain=sample(1:n,n1)\n\t## estimation of the logistic regression model\n\t## explanatory variables: carrier, destination, origin, weather, day of week\n\t## (weekday/weekend), scheduled hour of departure\n\t## create design matrix; indicators for categorical variables (factors)\n\tXdel <- model.matrix(delay~.,data=del)[,-1]\n\tXdel[1:3,]\n\txtrain <- Xdel[train,]\n\txnew <- Xdel[-train,]\n\tytrain <- del$delay[train]\n\tynew <- del$delay[-train]\n\tm1=glm(delay~.,family=binomial,data=data.frame(delay=ytrain,xtrain))\n\tsummary(m1)\n\t## prediction: predicted default probabilities for cases in test set\n\tptest <- predict(m1,newdata=data.frame(xnew),type=\"response\")\n\tdata.frame(ynew,ptest)[1:10,]\n\t## first column in list represents the case number of the test element\n\tplot(ynew~ptest)\n\t26\n\t## coding as 1 if probability 0.5 or larger\n\tgg1=floor(ptest+0.5) ## floor function; see help command\n\tttt=table(ynew,gg1)\n\tttt\n\terror=(ttt[1,2]+ttt[2,1])/n2\n\terror\n\t## coding as 1 if probability 0.3 or larger\n\tgg2=floor(ptest+0.7)\n\tttt=table(ynew,gg2)\n\tttt\n\terror=(ttt[1,2]+ttt[2,1])/n2\n\terror\n\tbb=cbind(ptest,ynew)\n\tbb\n\tbb1=bb[order(ptest,decreasing=TRUE),]\n\tbb1\n\t## order cases in test set according to their success prob\n\t## actual outcome shown next to it\n\t## overall success (delay) prob in the evaluation data set\n\txbar=mean(ynew)\n\txbar\n\t## calculating the lift\n\t## cumulative 1’s sorted by predicted values\n\t## cumulative 1’s using the average success prob from evaluation set\n\taxis=dim(n2)\n\tax=dim(n2)\n\tay=dim(n2)\n\taxis[1]=1\n\tax[1]=xbar\n\tay[1]=bb1[1,2]\n\tfor (i in 2:n2) {\n\taxis[i]=i\n\tax[i]=xbar*i\n\tay[i]=ay[i-1]+bb1[i,2]\n\t}\n\taaa=cbind(bb1[,1],bb1[,2],ay,ax)\n\taaa[1:100,]\n\tplot(axis,ay,xlab=\"number of cases\",ylab=\"number of successes\",main=\"Lift:\n\tCum successes sorted by pred val/success prob\")\n\tpoints(axis,ax,type=\"l\")","metadata":{"execution":{"iopub.status.busy":"2022-11-06T21:26:36.304599Z","iopub.execute_input":"2022-11-06T21:26:36.305967Z","iopub.status.idle":"2022-11-06T21:26:36.354897Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"","metadata":{},"execution_count":null,"outputs":[]}]}