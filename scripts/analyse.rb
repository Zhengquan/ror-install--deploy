#!/usr/bin/env ruby
require 'rubygems'
require 'hz2py'
#Name:  analyse.rb
#Desc:  a ruby script
#author:yangkit
#email: yangzhengquan@gmail.com
#

name_file = File.new "profiles_name.txt","r"
image_file = File.new "profiles_images.txt","r"
##姓名 
kx_result = File.new "kx_result.txt","w"

##刷新文件流，并关闭文件
flush_close = lambda{ |f| f.flush; f.close }

##根据File,返回数组
file_array =
  lambda{ |fs| 
    array = Array.new
    while line=fs.gets do
      array << line
    end
    return array
}

#去重,并过滤非法图象名称，姓名
def array_uniq!(array)
  array.each do |item|
    first = item.split(" ")[0]
    if (yield first)
      array.delete item
    end
  end
  array.uniq!
  return array
end

##从数组中随机返回一个Obejct
rand_obj = lambda{ |array|
  index = rand(array.size)
  value = array[index]
  value
}

##去除图象中得特殊符号
images = array_uniq!(file_array.call image_file){ |item| (item =~ /120_0_0\.gif|120_1_0\.gif/).nil? ? false : true }


##去除姓名中特殊字符
names = array_uniq!(file_array.call name_file){ |item| (item =~ /[a-zA-Z]+/).nil? ? false: true }  

#随机匹配
min_size = images.size > names.size ? names.size : images.size
min_size.times do
  img = rand_obj.call images
  name = ""
  while true do
    name = rand_obj.call names
    next if name.split(" ")[-1] != img.split(" ")[-1]
    break
  end

  ##删除已经使用的元素
  images.delete img
  names.delete name

  ##写入文件
  real_name = name.split(" ")[0]
  email = Hz2py.do(real_name).gsub(/\s/,"") + "@xl.com"
  password = "password"
  agender = name.split(" ")[-1]
  img_path = img.split(" ")[0]
  kx_result << [ real_name,email,password,agender,img_path ].join("\t") + "\n"
end

name_file.close
image_file.close
flush_close.call kx_result
