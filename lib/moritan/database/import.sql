drop table if exists users;
create table users(
  id         integer primary key,
  twitter_id text,
  context    text,
  last_date  datetime,
  created_at timestamp,
  updated_at timestamp
);

drop table if exists credits;
create table credits(
  id         integer primary key,
  user_id    integer,
  aa_times   integer, -- A+ 4
  a_times    integer, -- A  3
  b_times    integer, -- B  2
  c_times    integer, -- C  1
  d_times    integer, -- D  0
  gpa        float,   -- GPA 
  total      integer, -- 単位取得総数
  created_at timestamp,
  updated_at timestamp
);
