classdef Demo < handle
    %UNTITLED 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        % ---basic infor---
        num_people;
        num_discount;
        freight;
        packing_fee;
        
        % ----------------
        enumeration_table;
        order_table;
        % ------result----
        Each_person_pay;
        used_coupon;
        use_coupon_id;
        total_pay;
        
        %----------another discount---------
        add_money;
        new_discount_value;
        new_total_pay;
        note_txt1='';
        note_txt2 = '';
        
        % ----------------
        Discounts; %{[over,minus], [over,minus] ...}
        Orders; %{[person_id, cost, packing_fee]}
        Coupons; %{[person_id, coupon value]}
        Weights;
        
        % -----UI-----
        get_num_UI;
        set_order_UI;
        bill_showing_UI;
        weight_bill_UI;
    end
    
    methods
        function obj = Demo()
            obj.get_num_UI = GetNum(obj);
        end
        
        function set_num_infor(obj,num_people,num_discount,freight,packing_fee)
            obj.num_people = num_people;
            obj.num_discount = num_discount;
            obj.freight = freight;
            obj.packing_fee = packing_fee;
            
            obj.set_order_UI = SetOrder(obj,num_people,num_discount,packing_fee);
        end
        
        function row = find_row_from_cell_double(~,cell1,total_row,target,pos)
            row = -1;
            for r = 1:total_row
                tmp_group = cell2mat(cell1(r));
                may_target = tmp_group(pos);
                if target == may_target
                    row = r;
                    break
                end
            end
        end
        
        function row = find_row_in_cell(~,name,cell,total_row)
            row = -1;
            for i = 1:total_row
                rowname = char(cell(i,1));
                if name == rowname
                    row = i;
                    break
                end
            end
        end
        
        function sorted_cell = sort_cell(~,cell)
            len = length(cell);
            x = zeros(1, len);
            for i = 1 : len
                    x(i) = cell{i}(1);
            end
            [~, ind] = sort(x);
            sorted_cell = cell(ind);
        end
        
        function Get_three_table(obj,Discounts,Orders,Coupons,Weights)
            fprintf('In get three \n')
            obj.Discounts = Discounts;
            obj.Orders = Orders;
            obj.Coupons = Coupons;
            obj.Weights = Weights;
        end
        
        function show_bill(obj)
            obj.bill_showing_UI = Bill_showing(obj);
        end
        
        function show_weight_bill(obj)
            obj.weight_bill_UI = Weighted_bill(obj);
        end
        
        function c = get_person_cost(obj,id)
            row = obj.find_row_from_cell_double(obj.Orders,obj.num_people,id,1);
            group = cell2mat(obj.Orders(row));
            c = group(2);
        end
        
        function c = get_person_packing(obj,id)
            row = obj.find_row_from_cell_double(obj.Orders,obj.num_people,id,1);
            group = cell2mat(obj.Orders(row));
            c = group(3);
        end
        
        function c = get_person_coupon(obj,id)
            a = cell2mat(obj.Coupons)
            row = obj.find_row_from_cell_double(obj.Coupons,obj.num_people,id,1);
            group = cell2mat(obj.Coupons(row));
            c = group(2);
        end
        
        function dis = get_discount(obj,money)
            discount_level = obj.get_discount_level(money);
            if discount_level == 0
                dis = 0;
            else
                group = cell2mat(obj.Discounts(discount_level));
                dis = group(2);
            end
        end
        
        function level = get_discount_level(obj,money)
            discount_level = -1;
            for i = 1:obj.num_discount
                group = cell2mat(obj.Discounts(i));
                over = group(1);
                if money < over
                    discount_level = i-1;
                    break
                end
            end
            if discount_level == -1 %用最大优惠
                level = obj.num_discount;
            elseif discount_level == 0 %没有优惠
                level = 0;
            else
                level = discount_level;
            end
        end
        
        
        function cost = get_pay_for(obj,p_id_group) % [person_1,person_2]
            fprintf('In get_pay_for\n')
            group = p_id_group
            P_num = length(p_id_group);
            coupon_group = zeros(1,P_num);
            for i = 1:P_num
                coupon_group(i)=obj.get_person_coupon(p_id_group(i));
            end
%             c_g = coupon_group
            coupon_use = max(coupon_group)
            goods_cost = 0;
            for i = 1:P_num
                id = p_id_group(i);
                goods_cost = goods_cost + obj.get_person_cost(id);
                goods_cost = goods_cost + obj.get_person_packing(id);
            end
            discount = obj.get_discount(goods_cost)
            cost = goods_cost - coupon_use - discount + obj.freight
            fprintf('over-----\n')
        end
        
        function value = fill_unit_person_list(obj,row,column)
            this_order = zeros(1,obj.num_people);
            for i = 1:obj.num_people
                this_order(i) = obj.order_table(row,i);
            end
            my_add_order = 0;
            for i = 1:obj.num_people
                if column == this_order(i)
                    my_add_order = i;
                    break
                end
            end
            
            after_add_group = zeros(1,my_add_order);
            for i = 1:my_add_order
                after_add_group(i)=this_order(i);
            end
            after_add_cost = obj.get_pay_for(after_add_group);
            if my_add_order == 1
                value = after_add_cost;
            else
                before_add_group = zeros(1,my_add_order-1);
                for i = 1:(my_add_order-1)
                    before_add_group(i)=this_order(i);
                end
                before_add_cost = obj.get_pay_for(before_add_group);
                value = after_add_cost - before_add_cost;
            end
        end
        
        function value = get_max_coupon(obj)
            coupon_group = zeros(1,obj.num_people);
            for id = 1:obj.num_people
                coupon_group(id)=obj.get_person_coupon(id);
            end
            value = max(coupon_group);
        end
        
        function group = find_who_use_coupon(obj,value)
            tmp_cell = {};
            for id = 1:obj.num_people
                his_coupon = obj.get_person_coupon(id);
                if his_coupon == value
                    tmp_cell{end+1}=id;
                end
            end
            group = cell2mat(tmp_cell);
        end
        
        function re = get_another_discount(obj) %re = 1 更优惠，re=0无法更优惠
            fprintf('get_another_discount\n')
            goods_cost = 0;
            for i = 1:obj.num_people
                goods_cost = goods_cost + obj.get_person_cost(i);
                goods_cost = goods_cost + obj.get_person_packing(i);
            end
            total_cost_not_fc = goods_cost
            
            discount_level = obj.get_discount_level(goods_cost)
            if discount_level==obj.num_discount
                re = 0;
            else
                new_dis_level = discount_level+1;
                group = cell2mat(obj.Discounts(new_dis_level));
                obj.new_discount_value = group(2)
                obj.add_money = group(1)-goods_cost
                coupon = obj.used_coupon;
                obj.new_total_pay = group(1) + obj.freight -coupon-obj.new_discount_value
                re = 1;
            end
            
        end
        
        function calculation(obj)
            row_num = factorial(obj.num_people);
            obj.enumeration_table = zeros(row_num,obj.num_people);
            person_list = zeros(1,obj.num_people);
            for id = 1:obj.num_people
                person_list(id) = id;
            end
            fprintf('order -----------\n')
            obj.order_table = perms(person_list)
            
            obj.total_pay = obj.get_pay_for(person_list);
            
            for r = 1:row_num
                for id = 1:obj.num_people
                    obj.enumeration_table(r,id) = obj.fill_unit_person_list(r,id);
                end
            end
            
            obj.Each_person_pay = zeros(1,obj.num_people);
            for id = 1:obj.num_people
                sum_value = 0;
                for j = 1:row_num
                    sum_value = sum_value + obj.enumeration_table(j,id);
                end
                final_pay = sum_value/row_num;
                obj.Each_person_pay(id)=final_pay;
            end
            
            order = perms(person_list)
            big_table = obj.enumeration_table
            obj.used_coupon = obj.get_max_coupon();
            obj.use_coupon_id = obj.find_who_use_coupon(obj.used_coupon);
            fprintf('calculate over\n')
            re = obj.get_another_discount()
            if re == 1
                txt1 = 'If you add another ';
                txt2 = num2str(obj.add_money);
                txt3 = 'RMB, you can minus ';
                txt4 = num2str(obj.new_discount_value);
                txt5 = 'RMB';
                
                txt21 = 'You total payment will be ';
                txt22 = num2str(obj.new_total_pay);
                txt23 = 'RMB'
                
                obj.note_txt1 = [txt1,txt2,txt3,txt4,txt5];
                obj.note_txt2 = [txt21,txt22,txt23];
            end
            fprintf('calculate add money\n')
        end
    end
end

