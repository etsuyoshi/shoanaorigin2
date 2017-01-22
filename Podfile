# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift
# use_frameworks!





# https://github.com/danielgindi/Charts/blob/master/ChartsDemo/Classes/Demos/HalfPieChartViewController.m
#
#
# global
# PieChartView *pieChartView;
#
# viewdidload
#
#
#
#
#
#
#




platform :ios, '10.0'
target 'shoana' do
  pod 'Charts', '3.0.1'
  pod 'Realm', '~> 2.2'
end
use_frameworks!


# target 'shoana' do
#   use_frameworks!
#   pod 'Charts/Realm'
# end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
