# Code optimization
* Unnecessary objects decrease performance substantially
* JSON generation takes time, more efficient increases performance noticeably
* installed rails-api to remove unessecary bloat

# SQL optimizations
* ActiveRecord generated sql does not always produce efficient queries that make use of available indexes, writing queries by hand may increase performance substantially

# Ruby versions

# Todo
* only select attributes needed for models and show difference in memory usage in thesis (eg skip created_at, updated_at etc)
* create chart of execution time for optimized and unoptimized database code

