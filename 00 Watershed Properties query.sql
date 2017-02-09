Watershed_Properties_Data= %%sql \
SELECT w.ws_property_id, w.location, w.property_type, l.city, l.state, l.zipcode, p.apt_house, p.num_bedrooms, p.kitchen, \
p.shared, w.current_monthly_rent, sample_price.percentile_10th_price, sample_price.percentile_90th_price, \
sample_price.sample_nightly_rent_price, sample_dates.Occupancy \
FROM watershed_property_info w, location l, property_type p, \
    (SELECT w.ws_property_id, w.location, w.property_type, \
     sp.percentile_10th_price, sp.percentile_90th_price, \
     sp.sample_nightly_rent_price \
     FROM watershed_property_info w JOIN st_rental_prices sp \
       ON w.location=sp.location AND w.property_type=sp.property_type \
     GROUP BY w.ws_property_id) AS sample_price, \
    (SELECT w.ws_property_id, w.location, w.property_type, Sample.Occupancy \
     FROM watershed_property_info w LEFT JOIN (SELECT si.location, si.property_type, sd.st_property, COUNT(sd.rental_date)/365 \
                                               AS Occupancy \
                                               FROM st_property_info si JOIN st_rental_dates sd \
                                                 ON si.st_property_id=sd.st_property \
                                               WHERE EXTRACT(year FROM rental_date)=2015 \
                                               GROUP BY st_property) AS Sample \
       ON w.location=Sample.location AND w.property_type=Sample.property_type \
     GROUP BY w.ws_property_id) AS sample_dates \
WHERE w.property_type=p.property_type_id AND w.location=l.location_id AND w.ws_property_id=sample_price.ws_property_id AND \
w.ws_property_id=sample_dates.ws_property_id \
GROUP BY w.ws_property_id;

Watershed_Properties_Data.csv('Watershed Properties Data.csv')