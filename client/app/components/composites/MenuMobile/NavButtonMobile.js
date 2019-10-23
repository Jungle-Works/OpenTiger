import { Component, PropTypes } from 'react';
import { div, span } from 'r-dom';
import css from './MenuMobile.css';
import leftArrowIcon from './images/left-arrow-chevron.svg';


class NavButtonMobile extends Component {

  render() {

    return (
      div({
        className: `MenuLabelMobile ${css.menuLabelMobile}`,
        id: "go-back-btn"
      },[
        span({
          dangerouslySetInnerHTML: {
            __html: leftArrowIcon,
          },
        }),
      ])
    );
  }

}


export default NavButtonMobile;
