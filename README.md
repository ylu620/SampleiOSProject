## Zenly Take Home Project - Ryan Lu

- What does this project do?
  - This project is a simple app that shows a list of users pulled from a service. Specifically, it consists on a collection view, which shows a list of picture of users; as well as a detailed view which shows more information of the user along with a high-def picture. At the moment the app pulls a hard coded 200 users at the time, this can be changed or exposed to be configurable by user of the app if needed in the future. You also have the option to refresh, which will pull another 200 random users.
- Time spent on project
  - I believe I spent roughly around 6-7 hours on this project
- Build Tools & Versions
  - Xcode 11, tested with various devices on iOS 12 & iOS 13
- Focus Areas
  - Performance: Performance was one of the biggest focuses of this project. In order to ensure a smooth user experience while saving user's bandwidth as much as possible, I tried to incorporate some common good practices when writing out the collection view, detailed view and the manager. You will find that all operations are performed on BG thread unless they need to be on main thread; collection view cells are reused and lazily loaded; images are cached after loading the first time; larger images are not downloaded or loaded unless needed, smaller images are presented in their absence, etc.
  - Programming Practices: There are a few principles which I tried to keep in mind while developing this fun little project
    1. **Architecture**: I decided to take advantage of the classic ModelViewController architecture for this project. Specifically, a model-owned networking version of MVC. I understand that MVC might not be the best pattern to follow given its downsides, however for these two reasons I believe it's ok to use MVC for now:
        -  this project is very small, the downsides of MVC are not obvious at all at this stage. If the project becomes more complex, then we should consider doing some refactor and switch to for example MVVM
        -  Using MVC considerably decreases overhead
    1. **Extensibility/scalability**: At Amazon often times we are required to write extensible, scalable code. So this is something I try to focus on when I write a feature.
      - A storage system is built for storing the user list and images locally. It's built using JSON. And it would be able to support a list which is much larger and dynamic.
    1. **Separation of concerns**: As mentioned earlier, this project takes advantage of the MVC architecture. And on top of that, things are broken down based on their specific functionalities. I tried to follow the 'Single Responsibility Principle' when designing this project.
      - The main classes and their functionalities are:
        - *ViewController*: the main UI entry point into the app, root VC. Instantiates the dependencies needed by subsequent classes
        - *PersonCollectionViewController*: the main view that the user will be interacting with which is a collection view that shows a vertical list of users
        - *Person*: an object that presents an user
        - *PersonManager*: A manager class that provides functionalities to deal with persons, such as get, save, downloadImage, etc
        - *PersonStorage*: The storage system based on JSON that allows us to store and retrieve person/user objects and the image resources
        - *ConnectionManager*: A networking layer that is in charge of downloading JSONs and images
    1. **Testability**: Testability was one of highest priorities for this project, that's why you can see that I applied the idea of protocol-based programming in some parts to allow for classes to be mockable. And you will find that when possible, all the dependencies are injected into the class.
  - Thread safety
      -  Since this project involves dynamically downloading assets and loading them, thread safety is definitely one of the biggest concerns. You can see that I added a queue in almost all the classes and wrapped external-facing functions inside of them, that's a way to make sure they are thread safe and weird behaviors don't happen
  - Cleanliness
    -  Extensions and // MARKs are used quite often as ways to separate things out and make things look cleaner and more single-purposed.
- Comprises made & future improvements: Though I had fun with the project, some comprises had to be made due to time constraint
  - Incomplete Unit Tests: Due to the demo nature of this project and the limited time, I only added tests for PersonManager as a way to demonstrate how I would approach testing & mocking usually. For a real life project the test coverage should be much higher.
  - Owner of constants: For now, I have decided to put constants. Potentially there could be improvements made on where is a good place for them
  - Storyboard vs Code: Initially I wanted to write the UI part in code instead of using storyboard. However, due to the time constants, I decided to make a comprise and use storyboard instead. But personally I am a bigger fan of laying out things programmatically, it's more precise and offers more control and customization.
  - UI/UX Design: Also due to the time constraint, the UI is kept to a very simplistic level which incorporates some elements that Zenly uses in its app.
  - API: This project uses the API provided by http://randomuser.me/ mentioned in the project description. A lot of information are included in the response but not all of them are used. I couldn't find anything in their docs about properties being optional so this project assumes are properties in responses are non-optional.
  - Network requests can not be canceled: You will find that in connection manager started network requests are not cancellable, this is not ideal and cancelling should be supported using a queue in the future
