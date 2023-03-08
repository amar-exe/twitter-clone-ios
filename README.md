# Twitter Clone

Started as code from the course at Udemy: https://www.udemy.com/course/twitter-ios-clone-swift/learn/lecture/17972087

After following the course I implemented additional functionalities like a message system, and also improved many features the course lacked or just didn't do properly.

### Other features besides the messaging feature:
- Pagination
- Database querying on user search
- No data screens
- Expandable bio label
- Pull to refresh on all screens where it makes sense
- Validation for login and register screens as well as showing the errors
- Circular image pickers to match with the circular profile image theme

Messages were implemented by iOS Academy's course: https://www.youtube.com/watch?v=Mroju8T7Gdo&list=PL5PR3UyfTWvdlk-Qi-dPtJmjTj-2YIMMf&index=1

## Podfile

```
target 'TwitterClone' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

	pod 'FirebaseAnalytics'
	pod 'FirebaseAuth'
	pod 'FirebaseFirestore'
	pod 'Firebase/Core'
	pod 'Firebase/Storage'
	pod 'Firebase/Database'
	pod 'SDWebImage', '~> 5.0'
	pod 'ActiveLabel'
	pod 'CropViewController'
	pod 'SnapKit', '~> 5.6.0'

	pod 'MessageKit'
	pod 'JGProgressHUD'
	pod 'RealmSwift'

	pod "ExpandableLabel"
end
```
