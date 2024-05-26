# Launch Your Static Website on AWS S3: A Beginner's Guide to High Availability and CDN

## The Mission

Imagine you've just come up with an incredible idea for a project. You're excited, you're motivated, and you can't wait to share it with the world. But there's a catch - your budget is tight. Don't worry, we've got you covered! You can create a stunning static website to showcase your idea without breaking the bank.

In today's digital landscape, Wordpress often takes the spotlight with its extensive features and plugins. However, it relies heavily on PHP to generate content on the fly, which can slow down your page load times. Plus, you'll need a webserver to host it, which can be a bit pricey.

Enter the world of static website hosting. With a static website, your content is ready to go as soon as your page is requested, leading to faster load times and a smoother user experience. And the best part? You can host your static website on an S3 bucket AWS, an affordable object storage solution that can hold your HTML, CSS, JS files, and even media assets like images and videos.

Combine your S3 bucket AWS with Cloudfront, a top-notch CDN, and you've got the perfect setup for your static website.

## Getting Started

Setting up your infrastructure might sound daunting, but it's actually quite straightforward. All you need is Cloudfront and an S3 bucket AWS.

To make things even easier, we'll automate the infrastructure deployment using Terraform. We'll also implement basic security checks on the Terraform code with Trivy as part of a pre-commit set of hooks. This way, you can focus on bringing your awesome idea to life while we handle the technicalities.