package com.cg.controller;

import org.dom4j.rule.Mode;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

@Controller
@RequestMapping("/customers")
public class CustomerController {

    @GetMapping
    public ModelAndView showListPage(){
        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("customer/list");
        modelAndView.addObject("fullName","ABC");
        return modelAndView ;
    }
//    @GetMapping
//    public String showListPage(){
//        return "customer/list";
//    }

    @GetMapping("/information")
    public String showInfoPage(){
        return "customer/information";
    }

    @GetMapping("/create")
    public String showCreatePage(){
        return "customer/create";
    }


}
