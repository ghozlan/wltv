function print_log(string)
    fprintf(string)
    global log_file
    fprintf(log_file,string);