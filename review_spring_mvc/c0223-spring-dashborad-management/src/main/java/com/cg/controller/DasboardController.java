package com.cg.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller

public class DasboardController {
    @RequestMapping(value = "", method = RequestMethod.GET)
    public String showDashboardPage() {
        return "dashboard";
    }


    @RequestMapping(value = "bill", method = RequestMethod.GET)
    public String showBillPage() {
        return "/bill";
    }

    @RequestMapping(value = "customer", method = RequestMethod.GET)
    public String showCustomerPage() {
        return "/customer";
    }

    @RequestMapping(value = "product", method = RequestMethod.GET)
    public String showProductPage() {
        return "product";
    }

    @RequestMapping(value = "staff", method = RequestMethod.GET)
    public String showStaffPage() {
        return "/staff";
    }

    @RequestMapping(value = "product/create", method = RequestMethod.GET)
    public String showCreateProduct(){
        return "product/create";
    }


}
