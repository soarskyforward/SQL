TYPE=TRIGGERS
triggers='CREATE DEFINER=`root`@`localhost` trigger neworder after insert on orders\nfor each row select NEW.order_num into @what'
sql_modes=1436549152
definers='root@localhost'
client_cs_names='utf8'
connection_cl_names='utf8_general_ci'
db_cl_names='utf8_general_ci'
created=156440895257
