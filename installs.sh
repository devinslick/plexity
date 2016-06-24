while read p; do
  if [[ ${p:0:1} == '*' ]];
  then
    echo "Run $p script"
  else
    echo "Yum install $p"
  fi
done < test
