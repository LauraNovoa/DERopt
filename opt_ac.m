%% ACs and AC Constraints

%% ACs
if isempty(acs_v) == 0
    for i=1:size(acs_v,2)
        Constraints=[Constraints
            acs_cool(:,i) <= acs_adopt(i)];
%         0 <= acs_cool(:,i)
%             0 <= acs_adopt(i)
    end
end

%% AC
if isempty(ac_v) == 0
    for i=1:size(ac_v,2)
        Constraints=[Constraints  
            ac_cool(1) == 0
            ac_cool(1:length(ac_op),i) <= ac_adopt(i)
            ac_cool(length(ac_op)+1:length(ac_cool),i) <= ac_adopt(i)            
            ac_cool(1:length(ac_op),i) <= 2*cooling_max.*ac_op(:,i) %%%AC Operational State
            ac_op(2:length(ac_op),i) - ac_op(1:length(ac_op)-1,i) <= ac_start(:,i) %%%AC Starting
            ac_v(5,i)*ac_adopt(i)  <= ac_chrg(:,i) + 2*cooling_max*(1 - ac_start(:,i))  %%%AC cooling is between 0 and installed AC capacity
            ac_v(6,i)*ac_adopt(i)  <= ac_cool(1:length(ac_op),i) + 2*cooling_max*(1 - ac_op(:,i))]; %%% AC output is limited by minimum chiller operation
         %%%Old version of the AC model - Change is to the min AC output
         %%%that is constrainted in the 1st line
%         ac_op(:,i) <= ac_cool(1:length(ac_op),i) <= ac_adopt(i)
%             ac_cool(length(ac_op)+1:length(ac_cool),i) <= ac_adopt(i)            
%             ac_cool(1:length(ac_op),i) <= 2*cooling_max.*ac_op(:,i) %%%AC Operational State
%             ac_op(2:length(ac_op),i) - ac_op(1:length(ac_op)-1,i) == ac_start(:,i) %%%AC Starting
%             ac_v(5,i)*ac_adopt(i)  <= ac_chrg(:,i) + 2*cooling_max*(1 - ac_start(:,i))];  %%%AC cooling is between 0 and installed AC capacity
        
        %%%Lower Bounds that were put in later
%         0 <= ac_adopt(i)
%         0 <= ac_op(:,i)
%             0 <= ac_start(:,i)
%             0 <= ac_chrg(:,i)
%              0 <= ac_cool(length(ac_op)+1:length(ac_cool),i)
    end
end

%% ACp
if isempty(acp_v) == 0
    for i=1:size(acp_v,2)
        Constraints=[Constraints
            acp_strg(2:length(acp_strg),i) == acp_v(7,i).*acp_strg(1:length(acp_strg)-1,i) + acp_chrg(:,i) - (1/acp_v(3,i)).*acp_dchrg(:,i) %%% Energy Balance for the AC
            acp_strg(:,i) <= acp_v(6,i)*acp_adopt(i) %%%AC Storage is limited by adopted chiller size
            acp_dchrg(:,i) <= (2*cooling_max)*acp_dchrg_op(:,i)
            acp_chrg(:,i) <= (2*cooling_max)*acp_chrg_op(:,i)
            acp_dchrg_op(:,i) + acp_chrg_op(:,i) <= 1];
        
        if acp_v(end) == 1
            Constraints=[Constraints
                acp_cool(1,i) <= (1/acp_v(6,i)).*acp_strg(1,i)
                acp_cool(2:winter_time_count,i) + acp_dchrg(:,i) <= (1/acp_v(6,i)).*acp_strg(2:winter_time_count,i)
                acp_cool(winter_time_count+1:endpts(length(endpts)),i) <= acp_adopt(i)];
%             acp_cool(1,i) <= acp_adopt(i)
%             acp_cool(2:winter_time_count,i) + acp_dchrg(:,i) <= acp_adopt(i)
            
            
%                 acp_cool(2:winter_time_count,i) + acp_chrg(:,i) <= (1/acp_v(3,i)).*acp_adopt(i)
%                 acp_cool(1,i) <= (1/acp_v(6,i)).*acp_strg(1,i) %%%AC Output at time t=1
%                 acp_dchrg(:,i) + acp_cool(2:winter_time_count,i) <= (1/acp_v(6,i)).*acp_strg(2:winter_time_count,i) %%%Cooling output is limited by charged state of absorption chiller
%                 acp_cool(1,i) <= (2*cooling_max)*acp_op(1,i)
%                 acp_dchrg(:,i) + acp_cool(2:winter_time_count,i) <= (2*cooling_max)*acp_op(2:winter_time_count,i) %%%Chiller output is smaller than arbitrarilly larger value
%                 acp_v(8,i)*acp_adopt(i) <= acp_cool(1,i) + (2*cooling_max)*(1 - acp_op(1,i))
%                 acp_v(8,i)*acp_adopt(i) <= acp_dchrg(:,i) + acp_cool(2:winter_time_count,i) + (2*cooling_max)*(1 - acp_op(2:winter_time_count,i))
%                 acp_cool(winter_time_count+1:endpts(length(endpts)),i) <= acp_adopt(i)];
            
        elseif acp_v(end) == 0
            Constraints=[Constraints
                acp_cool(2:endpts(length(endpts)),i) + acp_chrg(:,i) <= (1/acp_v(3,i)).*acp_adopt(i)
                acp_cool(1,i) <= (1/acp_v(6,i)).*acp_strg(1,i) %%%AC Output at time t=1
                acp_dchrg(2:endpts(length(endpts)),i) + acp_cool(:,i) <= (1/acp_v(6,i)).*acp_strg(2:endpts(length(endpts)),i) %%%Cooling output is limited by charged state of absorption chiller
                acp_cool(1,i) <= (2*cooling_max)*acp_op(1,i) %%%Chiller output is smaller than arbitrarilly larger value
                acp_dchrg(:,i) + acp_cool(2:endpts(length(endpts)),i) <= (2*cooling_max)*acp_op(2:endpts(length(endpts)),i) %%%Chiller output is smaller than arbitrarilly larger value
                acp_v(8,i)*acp_adopt(i) <= acp_cool(1,i) + (2*cooling_max)*(1 - acp_op(1,i)) %%%Minimum operation
                acp_v(8,i)*acp_adopt(i) <= acp_dchrg(:,i) + acp_cool(2:endpts(length(endpts)),i) + (2*cooling_max)*(1 - acp_op(2:endpts(length(endpts)),i))]; %%%Minimum operation
            
        end
        
        
        
    end
end