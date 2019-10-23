import { Component, PropTypes } from 'react';
import r,{ div, span } from 'r-dom';
import css from './MenuMobile.css';
import hamburgerIcon from './images/hamburgerIcon.svg';
import NavButtonMobile from './NavButtonMobile';

class MenuLabelMobile extends Component {

  render() {
    const extraClasses = this.props.extraClasses ? this.props.extraClasses : '';
    const locale = this.props.location.split('/');
  
    return (( locale[1]  == '') || ((locale[1] == I18n.locale) && (locale.length == 2)) || (locale[1].startsWith(I18n.locale+"?"))
     || (locale[1].startsWith(I18n.locale + "/?")) ||  (locale[1].startsWith("?")) ) ? (
      div({
        className: `MenuLabelMobile ${css.menuLabelMobile} ${extraClasses}`,
        onClick: this.props.handleClick,
      }, [
        span({
          className: css.menuLabelMobileIcon,
          title: this.props.name,
          dangerouslySetInnerHTML: {
            __html: hamburgerIcon,
          },
        }),
      ].concat(this.props.children)) 
        // r(NavButtonMobile)
    ) :  r(NavButtonMobile);
  }
}

MenuLabelMobile.propTypes = {
  name: PropTypes.string.isRequired,
  handleClick: PropTypes.func.isRequired,
  extraClasses: PropTypes.string,
  children: PropTypes.oneOfType([
    PropTypes.arrayOf(PropTypes.node),
    PropTypes.node,
  ]),
};

export default MenuLabelMobile;
