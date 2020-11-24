/* Transform all data to weekly format*/

select * from mmm.mmm_sales_raw;

select * from mmm.mmm_date_metadata;

create table mmm.mmm_sales_transformed
(
select b.`Week`, round(sum(Sales), 2) as sales
from mmm.mmm_sales_raw as a
left join mmm.mmm_date_metadata as b
on a.`Order Date`  = b.`Day`
group by b.`Week`
);

select * from mmm.mmm_sales_transformed;

select * from mmm.mmm_comp_media_spend;

select * from mmm.mmm_date_metadata;

create table mmm.mmm_comp_transformed
(
select `Week`, Round(Sum(`Competitive Media Spend`), 2) as total_comp_spend
from mmm.mmm_comp_media_spend
group by `Week`
);

select * from mmm.mmm_comp_transformed;

select * from mmm.mmm_event;

create table mmm.mmm_event_transformed
(
select `Week`, max(if(`Sales Event`=1, 1, 0)) as `sales_event`
from mmm.mmm_date_metadata as a
left join mmm.mmm_event as b
on a.`Day` = b.`Day`
group by `Week`
);

select * from mmm.mmm_event_transformed;

select * from mmm.mmm_econ;
select * from mmm.mmm_date_metadata;

create table mmm.mmm_econ_transformed
(
select b.`WEEK`, CCI from mmm.mmm_econ as a
left join mmm.mmm_date_metadata as b
on a.`MONTH`=b.`MONTH`
group by b.`week`, CCI
);

select * from mmm.mmm_sales_transformed;

create table mmm.mmm_offline_transformed
(
select `Date`, round(sum(`TV GRP`/100*`Total HH`)/sum(`Total HH`)*100, 1) as `National TV GRP`
, round(sum(`Magazine GRP`/100*`Total HH`)/sum(`Total HH`)*100, 1) as `National Magazine GRP`
from mmm.mmm_offline_raw a
left join mmm.mmm_dma_hh b
on a.`DMA` = b.`DMA Name`
group by `Date`
);

select * from mmm.mmm_offline_transformed;

/* Upsert Display Data*/
		   
CREATE TABLE mmm.mmm_dcmdisplay_transformed
(
SELECT
`Date`
,SUM(CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER)) AS `DisplayImpressions`
,SUM(IF(`Campaign Name` LIKE '%Always-On%',CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayAlwaysOnImpressions`
,SUM(IF(`Campaign Name` LIKE '%Website%',CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayWebsiteImpressions`
,SUM(IF(`Campaign Name` IN ('Branding Campaign','New Product Launch'),CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayBrandingImpressions`
,SUM(IF(`Campaign Name` IN ('Holiday','July 4th'),CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayHolidayImpressions`
,SUM(CONVERT(REPLACE(`Clicks`,',',''), SIGNED INTEGER)) AS `DisplayClicks`
,SUM(CONVERT(REPLACE(`Video Started`,',',''), SIGNED INTEGER)) AS `DisplayVideoStarted`
,SUM(CONVERT(REPLACE(`Video Fully Played`,',',''), SIGNED INTEGER)) AS `DisplayVideoFullyPlayed`
FROM mmm.mmm_dcmdisplay_2015
GROUP BY `Date`
);

CREATE TEMPORARY TABLE mmm.dcm_temp
(
SELECT
`Date`
,SUM(CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER)) AS `DisplayImpressions`
,SUM(IF(`Campaign Name` LIKE '%Always-On%',CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayAlwaysOnImpressions`
,SUM(IF(`Campaign Name` LIKE '%Website%',CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayWebsiteImpressions`
,SUM(IF(`Campaign Name` IN ('Branding Campaign','New Product Launch'),CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayBrandingImpressions`
,SUM(IF(`Campaign Name` IN ('Holiday','July 4th'),CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayHolidayImpressions`
,SUM(CONVERT(REPLACE(`Clicks`,',',''), SIGNED INTEGER)) AS `DisplayClicks`
,SUM(CONVERT(REPLACE(`Video Started`,',',''), SIGNED INTEGER)) AS `DisplayVideoStarted`
,SUM(CONVERT(REPLACE(`Video Fully Played`,',',''), SIGNED INTEGER)) AS `DisplayVideoFullyPlayed`
FROM mmm.mmm_dcmdisplay_2017
GROUP BY `Date`
);

SELECT * 
FROM mmm.mmm_dcmdisplay_transformed a
INNER JOIN mmm.dcm_temp b
ON a.`Date` = b.`Date`
;

USE mmm;

DELETE a
FROM mmm.mmm_dcmdisplay_transformed a
INNER JOIN mmm.dcm_temp b
ON a.`Date` = b.`Date`
;

INSERT INTO mmm.mmm_dcmdisplay_transformed
SELECT * FROM mmm.dcm_temp
;

/* Upsert Paid Search Data*/
     
select * from mmm.mmm_adwordssearch_2015;
select * from mmm.mmm_adwordssearch_2017;

create temporary table mmm.mmm_temp
(
select * from mmm.mmm_adwordssearch_2017
);

select * from mmm.mmm_adwordssearch_2015 a
inner join mmm.mmm_temp b
on a.`date_id` = b.`date_id`;

use mmm;

delete a
from mmm.mmm_adwordssearch_2015 a
inner join mmm.mmm_search_temp b
on a.`date_id` = b.`date_id`;

insert into mmm.mmm_adwordssearch_2015
select * from mmm.mmm_temp;

create table mmm.mmm_search_extracted
(select * from mmm.mmm_adwordssearch_2015);

select * from mmm.mmm_search_extracted;

create table mmm.mmm_adwordssearch_transformed
(
select b.`Week`, sum(`impressions`) as `SearchImpressions`, sum(`clicks`) as `SearchClicks`
from mmm.mmm_search_extracted a
left join mmm.mmm_date_metadata b
on a.`date_id` = b.`Day`
group by b.`Week`
);

create table mmm.mmm_search_campaign_transformed
(
select b.`Week`
, sum(if(a.`campaign_name` like '%Always-On%', `clicks`, NULL)) as `SearchAlwaysOnClick`
, sum(if(a.`campaign_name` in ('Landing Page','Retargeting'), `clicks`, NULL)) as `SearchWebsiteClick`
, sum(if(a.`campaign_name` like '%Branding Campaign%', `clicks`, NULL)) as `SearchBrandingClick`
from mmm.mmm_search_extracted a
left join mmm.mmm_date_metadata b
on a.`date_id` = b.`Day`
group by b.`Week`
);

select * from mmm.mmm_search_campaign_transformed;

select * from mmm.mmm_facebook;

create table mmm.mmm_facebook_transformed
(
select `Period`
, ap_total_imps as `FacebookImpressions`
, ap_total_clicks as `FacebookClicks`
, if(ap_total_clicks!=0, round((ap_total_clicks/ap_total_imps), 3), 0) as `FacebookCTR`
from mmm.mmm_facebook
);

select * from mmm.mmm_facebook_transformed;
select distinct `Campaign Objective` from mmm.mmm_facebook;

create table mmm.mmm_fb_campaign_transformed
(
select b.`Week`
, sum(if(a.`Campaign Objective` like '%Branding Campaign%', ap_total_imps, 0)) as `FBBrandingImpression`
, sum(if(a.`Campaign Objective` like '%Holiday%', ap_total_imps, 0)) as `FBHolidayImpression`
, sum(if(a.`Campaign Objective` in ('Pride', 'July 4th', 'New Product Launch', 'Others'), ap_total_imps, 0)) as `FBOtherImpression`
from mmm.mmm_facebook a
left join mmm.mmm_date_metadata b
on a.`Period` = b.`Day`
group by b.`Week`
);
  
select * from mmm.mmm_wechat;

create table mmm.mmm_wechat_transformed
(
select `Period`
, (`Article Total Read`+`Account Total Read`+`Moments Total Read`) as `WechatTotalRead`
, sum(if(`Campaign` like 'New Product Launch', (`Article Total Read`+`Account Total Read`+`Moments Total Read`), 0)) as `WechatNewLaunchRead`
from mmm.mmm_wechat
group by `Period`, `WechatTotalRead`
);

create table mmm.mmm_holiday_event
(
select `Week`
, if(`Week` in ('2014-07-07', '2015-07-06', '2016-07-04', '2017-07-03'), 1, 0) as `July 4th`
, if(`Week` in ('2014-11-24', '2015-11-30', '2016-11-28', '2017-11-27'), 1, 0) as `Black Friday`
from mmm.mmm_sales_transformed
group by `Week`, `July 4th`, `Black Friday`
);
select * from mmm.mmm_search_campaign_transformed;

/* Create analytical file*/
      
create view mmm.af AS
select
t5.`Period`,
m.`Month`,
t1.`CCI`,
t2.`National TV GRP`,
t2.`National Magazine GRP`,
t3.`DisplayImpressions` as `Display`,
t4.`SearchClicks` as `Paid Search`,
t5.`FacebookImpressions` as `Facebook`,
t6.`WechatRead`,
t7.`sales_event` as `Sales Event`,
t8.`Black Friday`,
t8.`July 4th`,
t9.`total_comp_spend` as `Comp Media Spend`,
t10.`sales`,
t3.`DisplayAlwaysOnImpressions`,
t3.`DisplayWebsiteImpressions`,
t3.`DisplayBrandingImpressions`,
t3.`DisplayHolidayImpressions`,
t11.`SearchAlwaysOnClick`,
t11.`SearchBrandingClick`,
t11.`SearchWebsiteClick`,
t12.`FBBrandingImpression`,
t12.`FBHolidayImpression`,
t12.`FBOtherImpression`
from (select distinct `Week`, `Month` from mmm.mmm_date_metadata) m
left join mmm.mmm_econ_transformed t1 on m.`Week` = t1.`WEEK`
left join mmm.mmm_offline_transformed t2 on m.`Week` = t2.`Date`
left join mmm.mmm_dcmdisplay_transformed t3 on m.`Week` = t3.`Date`
left join mmm.mmm_adwordssearch_transformed t4 on m.`Week` = t4.`Week`
left join mmm.mmm_facebook_transformed t5 on m.`Week` = t5.`Period`
left join mmm.mmm_wechat_transformed t6 on m.`Week` = t6.`Period`
left join mmm.mmm_event_transformed t7 on m.`Week` = t7.`Week`
left join mmm.mmm_holiday_event t8 on m.`Week` = t8.`Week`
left join mmm.mmm_comp_transformed t9 on m.`Week` = t9.`Week`
left join mmm.mmm_sales_transformed t10 on m.`Week` = t10.`Week`
left join mmm.mmm_search_campaign_transformed t11 on m.`Week` = t11.`Week`
left join mmm.mmm_fb_campaign_transformed t12 on m.`Week` = t12.`Week`
;

select * from mmm.af;
