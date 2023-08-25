DROP TABLE IF EXISTS hera_shard_map;
CREATE TABLE hera_shard_map (SCUTTLE_ID INT, SHARD_ID INT, STATUS CHAR(1), READ_STATUS CHAR(1), WRITE_STATUS CHAR(1), REMARKS VARCHAR(500));

drop procedure if exists populate_shard_map;

delimiter #
create procedure populate_shard_map()
begin

declare v_max int unsigned default 128;
declare v_counter int unsigned default 0;

  while v_counter < v_max do
    INSERT INTO hera_shard_map VALUES (v_counter, mod(v_counter, 5),'Y','Y','Y','Initial');
    set v_counter=v_counter+1;
  end while;
  commit;
end #

delimiter ;

call populate_shard_map();


