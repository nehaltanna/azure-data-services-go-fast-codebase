python3 -m venv .dbtenv
source ./.dbtenv/bin/activate

pip install dbt-core --quiet 
pip install dbt-sqlserver --quiet 

#echo '.dbtenv/' > .gitignore         
export DBT_PROFILES_DIR=./.dbt/
